---
title: "Code Splitting with Meteor Dynamic Imports and React Loadable"
layout: post
date: 2017-08-26 17:00
tag:
- React
- Meteor
- Skoolers
category: blog
image: /images/component-level-splitting.png
description: "Smart bundling for dummies"
---
After [trimming server code from the client bundle](/blog/trimming-server-code-from-meteor-bundle), I still had some work to do and took a look at the new [dynamic import](https://blog.meteor.com/dynamic-imports-in-meteor-1-5-c6130419c3cd) functionality added in Meteor 1.5.

MDG [posted](https://blog.meteor.com/meteor-1-5-react-loadable-f029a320e59c) that they got [react-loadable](https://github.com/thejameskyle/react-loadable) working with Meteor 1.5 without any hiccups, so I set about seeing if my process would be as streamlined.

## Seriously easy bundle trimming with react-loadable

Turns out it was incredibly easy to get it up and running, I decided to use route-based dynamic loading at the high level (I could add component-based dynamic loading down lower if I felt that need later). All I needed to do was create my own wrapper to show the loading object when a Component is loading:

```jsx
import React from 'react';
import PropTypes from 'prop-types';

import Loading from '/imports/ui/components/Loading';

const LoadableLoading = ({ isLoading, pastDelay, error }) => {
  if (isLoading && pastDelay) {
    return <Loading />;
  } else if (error && !isLoading) {
    return (
      <h2>Error loading page!</h2>
    );
  }

  return null;
};

LoadableLoading.propTypes = {
  isLoading: PropTypes.bool.isRequired,
  pastDelay: PropTypes.bool.isRequired,
  error: PropTypes.object,
};

export default LoadableLoading;
```

Create a HOC to tell react-loadable to use my component:
```jsx
import Loadable from 'react-loadable';

import LoadableLoading from './LoadableLoading';

export default function LoadableWrapper(opts) {
  return Loadable({
    loading: LoadableLoading,
    ...opts,
  });
}
```

A lastly shift my routing page components to use the loadable wrapped components:

```jsx
import LoadableWrapper from './loadable/LoadableWrapper';

const Admin = LoadableWrapper({ loader: () => import('/imports/ui/pages/admin/Admin') });
const Course = LoadableWrapper({ loader: () => import('/imports/ui/pages/course/Course') });
...
Course.preload();
```

### Benefit #1 - Lazy load large third-party libraries (rich text editor, interactive tables, etc...)
And that was all! The savings were not just in the UI pages and components that I created, but also in the many packages I used for various parts of the UI once the user gets deeper into the site, including my rich text editor of choice ([Froala](https://github.com/froala/react-froala-wysiwyg)) and the fantastic [react-bootstrap-table](https://github.com/AllenFang/react-bootstrap-table) package. Both of those packages are hugely beneficial for the UI, but can definitely afforded to be lazy loaded after the rest of the page is loaded.

### Benefit #2 - Only send admin UI components to users who will use them
This on-demand loading now prevents sending the large amount of admin-related components to every user, since now I could allow those to be loaded on demand and cached by the clients when needed.

### Benefit #3 - Minimal main bundle size, negligible additional loading latency
In order to minimize the chance of the users ever seeing an extra loading indication from all this lazy loading, I go ahead and preload all of the page routes where students will visit, which are then cached in the client. This caching is ideal, as it will load components from cache even after a new app version is pushed if that component has not changed.

The main case where it could slightly impact load times is if a user lands on a page not in the main bundle with no cache, as an extra trip will be required to load that page component before a complete render, but after testing this adds under 300ms of load time in this hopefully uncommon case.

## Final bundle size - Nice and trim

After a short time working to trim the bundle, I was dropped my bundle size from **~4MB down to 1.7MB**.

<div class="side-by-side">
    <div class="toleft">
		<img class="image" src="/images/skoolers-small-bundle.png" alt="Skoolers Small Bundle">
    </div>
	<div class="toright">
        <h2>Boom, victory</h2>
        <p>This comes out to <500 KB gzipped, giving the site a <2 second load time.</p>
	</div>
</div>

After looking through the bundle contents in detail I'm satisfied with the current level of bundle size optimization with the site. Skoolers in particular has a very high rate of return users, and I don't push constant cache-busting updates mid-semester, so spending excessive effort to trim the bundle as much as possible isn't worth at this point.

## Note about using a CDN

Right now the server load is small enough that a CDN isn't necessary. If the traffic picks up enough that I need to spin up significant additional containers, I'd test out putting a CDN in place, at which point a lot of the dynamic loading would end up transferring load off the CDN onto the webservers. I'd likely end up putting a good deal of the route components back in the main bundle to allow the CDN to cache and deliver them in bulk.
