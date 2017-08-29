---
title: "Wrapping Vimeo Async API with Sync Wrapper"
layout: post
date: 2017-05-16 17:00
tag:
- API
- Vimeo
category: blog
image: /images/video-icon.png
description: "The ES7 ladder to escape from callback hell"
---
When building out the new video website platform for [Skoolers](/projects/skoolers), I needed something that could manage thousands of videos spread across hundreds of different projects. Not only did I need a way for the tutors to easily upload and share their videos, but I needed a system to keep them organized by project without painstaking fumbling through an awkward third party website.

After reading through all of the documentation for [Vimeo's API](https://github.com/vimeo/vimeo.js), I was impressed enough to start building a solution on top of it. They had relatively recently updated their API and it seemed well enough designed to do everything I needed it to do.

## The task - Syncing local DB with Vimeo library

I needed to ensure my DB stayed in sync with the Vimeo library, so that would involve a carefully planned run through the API to check all the online videos. The process would go something like this.

1. Get the list of all albums (Vimeo has different types of 'collections' of videos, 'albums' is the type that we want).
2. Because of the [API pagination](https://developer.vimeo.com/api/common-formats), we may have to call again to get the complete album list. We won't know until we receive the response of the first call.
3. After we get the complete album list, for each album:
    1. Get the list of videos in that album.
    2. Again, because of pagination we may have to call multiple times to get all the videos in that album.
    3. Go through each video and update our DB with the updated information.

Just thinking through the callbacks necessary to do all this properly gives me a mild headache. Keeping in mind that this functionality was core to the entire application, I needed to make sure this code was clean to read and maintain, could handle all the edge cases, and could be easily adjusted if/when the API changes.

## Promises to the rescue?

My first solution uses promises to manage everything, using arrays of them to manage the pagination, and using `Promise.all()` to resolve once all the calls were complete. I'm not going to list the code here as it wouldn't be very helpful, but needlessly to say it wasn't a great solution. I still ended up with a good deal of nesting and complexity that made it tricky to manage edge cases with certainty. It worked, was better than a mess of callbacks with repeated error handling calls all over the place, but wasn't everything I was looking for.

## Async/await wrapping saves the day!

Instead of dealing with nested callbacks or arrays of promises, what if I could just write non-blocking sync code that waits for response from Vimeo or throws an exception if something bad happens? Such magic seems to good to be true, but I suspended my doubts and set about making it happen.

Although I mentioned [ES7 async/await](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/await), I actually used Meteor's [wrapAsync](https://docs.meteor.com/api/core.html#Meteor-wrapAsync) to actually wrap the API in a sync framework. They both would work for the purpose, but I had already used wrapAsync at other points in the project and was familiar enough with it.

Below is the wrapper function around the API to both transform the calls into sync calls and manage the rate limiting.

```js
import VimeoAPI from 'vimeo';

import VimeoRateLimit from './rate-limit';

const VimeoLib = {};

// Store some constants specific to the Vimeo API
VimeoLib.constants = {
  MAX_RESULTS_PER_PAGE: 100, // Per Vimeo documentation
  VIDEO_FIELD_FILTER: 'uri,name,duration,created_time,modified_time,status', // The video fields we care about
  ...
};

// Initialize the Vimeo NodeJS API
VimeoLib.API = new VimeoAPI.Vimeo(
  Meteor.settings.vimeo.clientId,
  Meteor.settings.vimeo.clientSecret,
  Meteor.settings.vimeo.accessToken,
);

VimeoLib.callVimeoApi = (request) => {
  // Verify with our rate limit that we are allowed to make a call right now
  VimeoRateLimit.newApiCall(request);

  logger.debug(`Request ${request.method} ${request.path} ${JSON.stringify(request.query)}`);

  // This wrapper accounts for the different structure of Vimeo API parameter setup for callback.
  // Since wrapAsync assumes the last parameter is function(err, res), need to wrap Vimeo.request
  const wrapVimeoCallback = (opts, callback) => {
    VimeoLib.API.request(
      opts,
      (error, data, statusCode, headers) => {
        callback(error, { data, statusCode, headers });
      },
    );
  };

  // Use Meteor's wrapAsync function to make call sync
  const syncVimeoCall = Meteor.wrapAsync(
    wrapVimeoCallback,
    VimeoLib.API,
  );

  let result;
  try {
    result = syncVimeoCall(request);
  } catch (err) {
    logger.info(`Vimeo API threw exception ${err}`, { err, request });
    throw new Meteor.Error(
      'vimeo.api.error',
      `The Vimeo API threw an error ${err}`,
    );
  }

  // Update the rate limit tracker with the limit Vimeo API returns
  VimeoRateLimit.updateRateLimitCallback(result, request);

  if (result.error) {
    logger.error(`Vimeo API returned an error status ${result.message}`, result);
    throw new Meteor.Error('vimeo.api.error', result.message);
  }

  logger.debug(`Data response ${JSON.stringify(result.data)}`);
  return result;
};
```

By using this wrapper, I could reduce my entire library update code to simple, readable code:

```js
const updateVimeo = () => {
  const albums = getAlbumList(); // This is actually an async call, that may make additional async calls for pagination

  albums.forEach((album) => {
    processAlbumData(album);

    const videos = getVideoList(album); // This is also an async call
    videos.forEach(video => processVideoData(album, video));
    removeDeletedVideos(album, videos);
  });

  removeDeletedAlbums(albums);
};
```

The functions to request data and handle pagination were equally simple to lay out:

```js
const getAlbumList = (page = 1) => {
  const fields = 'uri,name,created_time,modified_time,metadata.connections.videos.uri';

  const result = VimeoLib.callVimeoApi({
    method: 'GET',
    path: '/me/albums',
    query: { fields, page, per_page: VimeoLib.constants.MAX_RESULTS_PER_PAGE },
  }, false);

  // If there are remaining pages, recursively call for the additional pages
  if (result.data.paging.next) {
    result.data.data = result.data.data.concat(getAlbumList(page + 1));
  }

  return result.data.data;
};
```

Since I rewrote the application to use this type of wrapper, I've had a much easier time working with the Vimeo API and making sure my application only tried to embed videos that Vimeo had finished processing and was ready to embed. All that's left is for them to eventually update the API to return promises to make this process even easier for other devs :).
