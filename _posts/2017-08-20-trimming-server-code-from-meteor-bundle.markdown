---
title: "Trimming Server Code from Meteor Bundle"
layout: post
date: 2017-08-20 17:00
tag:
- React
- Meteor
- Skoolers
category: blog
image: /images/meteor-logo.png
description: "Trimming MB of unused minified JS code from the main bundle"
---
After finishing up the feature set of [Skoolers](https://www.skoolerstutoring.com), it was time to take a look back to see how I could apply a little optimization to the site. The [Meteor](https://www.meteor.com/) bundler takes care of minifying and packaging up your CSS and JS, so went to take a look at what it was putting together behind the scenes.

## Big fat Meteor bundle

When someone lands on your Meteor page the first time, they need to grab the entire main bundle until they even begin rendering or subscribing to any data (this assumes you haven't built any SSR). So you want to make sure that main bundle isn't bloated. After [browsing some forums](https://forums.meteor.com/t/how-large-is-your-app/36944) on the subject, it looks like they tend to bloat pretty easily.

The first step to check the bundle was to use the handy new [bundle visualizer](https://blog.meteor.com/putting-your-app-on-a-diet-with-meteor-1-5s-bundle-visualizer-6845b685a119) tool released with Meteor 1.5 to check out what was being lumped into the main bundle. This is what it first looked like:

<div class="side-by-side">
	<div class="toleft">
		<img class="image" src="/images/skoolers-large-bundle.png" alt="Skoolers Large Bundle">
	</div>
    <div class="toright">
        <p>About <strong>4MB</strong> of minified JavaScript, woah. Time to get dirty trimming some junk!
        Worst offenders in the bundle include:</p>
        <ul>
            <li>aws-sdk</li>
            <li>winston - don't ask me how it got in there, it's in a server only file</li>
            <li>useragent - only used in a few dev admin pages</li>
            <li>an entire SECOND copy of react and react-dom, included via a <a href="https://github.com/AllenFang/react-bootstrap-table/issues/969">poorly maintained secondary dependency</a></li>
        </ul>
    </div>
</div>
## Stop sending server only code to client

I was using the [aws-sdk](https://www.npmjs.com/package/aws-sdk) package to allow clients to upload various files to our S3 buckets. Since I want to control access to those buckets, when the client wanted to upload it would call a Meteor method that would generate a token using the aws-sdk package on the server which gets returned via the method.

The code to generate that token was only run on the server, enforced with a `Meteor.isSimulation` condition, but since I was had `import AWS from 'aws-sdk';` at the top, the bundler was including about 1MB worth of code in that main bundle that was never run.

To fix this I needed to add a conditional import that would make sure to not package up the code in the client bundle. The file `./server/lib` simply exported a default object which performed the function using the aws-sdk package that I needed to call.

```js
let S3 = {};
if (Meteor.isServer) {
  S3 = require('./server/lib').default;
}
```

Taking out aws-sdk and some other fat server-only deps shaved off a nice a few MB, but I still had some work to do, so I continued the bundle trimming by switching to using [dynamic imports](/blog/code-splitting-with-meteor-dynamic-imports-and-react-loadable).
