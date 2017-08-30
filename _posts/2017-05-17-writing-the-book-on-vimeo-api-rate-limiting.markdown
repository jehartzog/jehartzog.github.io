---
title: "Writing the Book on Vimeo API Rate Limiting"
layout: post
date: 2017-05-17 17:00
tag:
- API
- Vimeo
category: blog
image: /images/video-icon.png
description: "When the simple seems impossible, keep nagging until it works"
---
When creating the video solution for [Skoolers](/projects/skoolers), I needed to work extensively with the Vimeo API, to include a full query against every album in the account, which I describe in some detail in [this post](/blog/wrapping-vimeo-async-api-with-sync-wrapper).

Obviously I needed to take a detailed look at the Vimeo API guidelines on rate limiting, and I was discouraged to find they were [empty of most useful information](https://developer.vimeo.com/guidelines/rate-limiting). Things I expected to see there but didn't:

* How many calls can I make in a unit of time?
* Is there a minimum amount of time between calls?

Turns out the only way to find these answers was to start making calls against library and find out what happened. I ended up finding out a number answers to those questions by trial + error.

## Consequences of being rate limited

In the course of my testing, I accidentally dropped `x-ratelimiting-remaining` to zero and kept making calls, which understandably made Vimeo not happy. When that happened, my API requests would return an error telling me of rate limiting status for exactly one hour starting when I first exceeded the limit. The response did not indicate the time when my access would be restored, nor did it return the typical rate limit headers, so it was on me to count the time.

## Vimeo API Ratelimit Overview

* The Vimeo API tracks the total number of calls you have made in a constantly rolling 15 minute window. 

* The `x-ratelimit-reset` response is useless, it always just returns a timestamp exactly 15 minutes ahead of your call.

* The `x-ratelimit-remaining` is a number to carefully watch, this is what you should use to track how many calls you are making and when to not allow any further calls.

* The `x-ratelimit-limit` is the important number you want to look at when setting up your application to make sure you are at a constant max value.

## Vimeo API's mysterious 15 minute rolling window

A few details on how this window works based on my observations. All of this is from estimations, not actually knowing how their servers work internally.

* They not perform any sort of averaging of calls per second or minute like most other API's.

* They store each request you make along with a timestamp. They then add up the number of requests, subtract that from `x-ratelimit-limit`, and that is your `x-ratelimit-remaining`.

* Every second or minute, they go through and delete any calls that are older than 15 minutes and recalculate the `x-ratelimit-remaining`.

* They say to not 'scrape' by making a bunch of calls at the same time, but I saw no evidence that following this actually made a difference. I wrote a throttler to space out repeated API calls by various increments (0ms, 5ms, 500ms, etc...) with no change to `x-ratelimit-limit`. The only enforcement mechanisms I saw were the calls allowed per 15 minute sliding window and the JSON filter fields setting that limit.

These rules have some odd effects to the end user, such that if you do a ton of operations at once and use up all your available calls, you need to wait exactly 15 minutes before making any additional calls, at which point they will all be suddenly restored.

## The magic of `x-ratelimit-limit`

If you browse the Vimeo API forums you'll see [post after post](https://vimeo.com/forums/api/topic:285701) of devs asking about why they are seeing very low rate limits as responses.

### Membership plan sets max limit

Based on the membership plan you have purchased, you are granted a different maximum `x-ratelimit-limit`:

Plan | Max `x-ratelimit-limit`
---|:---:
Basic | 250
Plus | 250
PRO | 500
Business | 1000

### How to actually get that max limit

Notice how I said 'max' limit above? When you first start making API calls, you'll most likely find your `x-ratelimit-limit` set to **100**! This extremely low number is what the API always sets when you don't use the [JSON field filter](https://developer.vimeo.com/api/common-formats#json-filter). As Vimeo says:

> In the words of one of our developers, "I pity the fool that doesn't use field filters" - [Vimeo support](https://vimeo.com/forums/api/topic:284070#comment_14822895)

This issue turns out to hit a [lot of devs](https://vimeo.com/forums/api/topic:288880#comment_15738963), as even APi calls where you don't even expect or look at the response body (`DELETE`, `PATCH`, etc..) will suddenly instantly drop your rate limit if you don't have those JSON field filters attached properly.

### Never fully trust the docs

Turns out, the documentation on how to use those all important JSON filter fields was incorrect. After working this issue for literally days, I came across [this forum post](https://vimeo.com/forums/api/topic:284100) where Vimeo support helped show a dev how to get a higher rate limit, and it doing so clued me on that his advice didn't match the documentation. I tested this out with my app and voila! No more 100 max limit.

The [current documentation](https://developer.vimeo.com/api/start) still says to append fields to the URI for `GET` requests, but for all other requests the parameters must be in the body. That is not how the actual API currently works, and I applied a small function to all outgoing requests which ensured my limited stayed at the max level (see [more context](/blog/wrapping-vimeo-async-api-with-sync-wrapper) for these functions):

```js
VimeoRateLimit.newApiCall = (request) => {
  // Compares previously stored values of `x-ratelimit-remaining` to `x-ratelimit-limit`,
  // throws exception if we are too close
  verifyWithinRateLimit(); 

  addFiltersToRequest(request);
};

// Their API doesn't work as documented, for non-GET requests must append JSON filter
// to path to get better rate limiting https://github.com/vimeo/vimeo.js/issues/51
const addFiltersToRequest = (request) => {
  if (request.method !== 'GET') {
    request.path += `?fields=${VimeoLib.constants.VIDEO_FIELD_FILTER}`;
  }
};
```

## Passing on the findings

To help prevent another dev from going through the same easter egg hunt I went through to find this out, I send a [PR](https://github.com/vimeo/vimeo.js/pull/54) which they accepted to update the [documentation](https://github.com/vimeo/vimeo.js#rate-limiting) on their Node.js library.

In the end, it took a ton of work to play nicely with the Vimeo rate limiting and still have a responsive application that could allow multiple users to upload/rename/edit videos simultaneously. Even at the current max of 1000 calls per 15 minutes, my app starts self-limiting uploads quickly when about 3+ users are working on uploading/renaming videos at the same time, so any plans for expansion will involve purchasing multiple Vimeo accounts based on the number of users.

## Feedback to Vimeo

Despite the difficulties with the libraries, I have nothing but praise for Vimeo support who were responsive and helpful on both forums, email, and github (especially Tommy!). It was their involvement which eventually led me to finding the solutions I needed.

Except for the rate limiting portion, I found the Vimeo API very easy to understand and work with, and it has proved very reliable in the 6+ months I've been using it so far. I would recommend anyone looking to build out a small/medium scale video solution take a close look at what Vimeo offers (unlimited bandwidth with their embedded video player, for example!!!).
