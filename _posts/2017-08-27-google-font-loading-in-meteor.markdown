---
title: "Google Font Loading in Meteor"
layout: post
date: 2017-08-27 17:00
tag:
- Meteor
category: blog
image: /images/meteor-logo.png
description: "A great mystery that shouldn't be"
---
In my search to load up some google fonts in Meteor, I found nothing in the official Meteor documentation about best practices, so search around community forums to figure out the best way to do to it right.

What I found was wrong information, bad information, and janky information. None of it terribly useful for my end solution, so I ended up going with the usual course when uncertainty strikes; trust google.

In this case, it was easy as they co-developed the [webfontloader](https://github.com/typekit/webfontloader) npm package and provided some clean documentation on how to use it.

## Posted solutions didn't quite pan out

I wanted a solution that didn't involve a ton of [monkey-patching Meteor](https://forums.meteor.com/t/how-to-include-fonts/16702) (the top google result) or using `@import` and [blocking all rendering](https://www.webucator.com/blog/2016/10/load-web-fonts-asynchronously-avoid-render-blocking-css/) while waiting for the fonts to load.

The best post I found was [this](https://forums.meteor.com/t/adding-google-fonts/1095/3) which led me to webfontloader, but the method they recommended would wait until your main package was delivered, than attached a script element to the DOM that would start downloading webfontloader, which would then start loading your desired fonts. All the while ensuring you get a nice long FOUT (flash of unstyled text) to wait for this chain of requests to complete.

## The balancing act of font loading

After reading through [google's tips](https://developers.google.com/web/fundamentals/performance/optimizing-content-efficiency/webfont-optimization#webfonts_and_the_critical_rendering_path), I settled on the solution below for a few reasons:

* The compact webfontloader JS is included in the main package, no need to wait for a second round trip before the browser even begins to download fonts. The webfontloader package is a very small addition to your main bundle, well worth the extra speed in getting the font downloaded.

* No render blocking at all, thanks to webfontloader replacing any `@import` css rules.

* Control over FOUT using a few simple CSS rules that work with webfontloader. I decided to hide the text until the fonts were loaded.

* Automatic [fallback](https://github.com/typekit/webfontloader#events) if google fonts fail to load.

## KISS shows its truth yet again

After we run `npm install -E webfontloader`, go ahead and tell the client to use it when it loads up. Notice I don't put this in a `Meteor.startup()` call, as I want it to be processed right away, not when the DOM is ready.

`/imports/client/load-fonts.js'
```js
import WebFont from 'webfontloader';

WebFont.load({
  google: {
    families: [
      'Nunito:regular,bold',
      'Lato:regular,bold,italic',
    ],
  },
});

```

This SCSS is optional, it prevents the FOUT by hiding the text, but falls back to showing it if the google font fails to load. I don't write a lot of CSS code, so keep that in mind :).

`/client/styles.scss`
```scss
h1,h2,h3,h4,h5,h6,p,a { 
    visibility: hidden; 
} 
 
.wf-active, .wf-inactive { 
    h1,h2,h3,h4,h5,h6,p,a { 
        visibility: visible; 
    } 
} 
```

After looking at the screenshots on a fresh render, this gives me exactly what I was looking for, quick page load that shows a layout that matches the end result, with the actual text hidden until the font is loaded within a second.

While something this common probably should be laid out in official documentation somewhere, it was still worth the effort as the end result ended up shaving almost a second off the initial load time where the website displays nothing but a white page while it waits for render blocking resources.
