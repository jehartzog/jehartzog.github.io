---
title: "Is Internet Explorer still evil?"
layout: post
date: 2016-05-12 17:00
tag:
- Website
- Internet Explorer
category: blog
description: "Don't be fooled, despite all the advancement Internet Explorer is still a terrible browser to support."
---
Enter 2016, the year of the modern browsers, where HTML/CSS/Javascript are powerful enough to drive native fully-featured [desktop applications](http://electron.atom.io/). Single page web applications can host fully-featured UI's that can go days without a page refresh necessary.

Browsers have come a long way to enable this incredible new functionality, and Microsoft has been trying to keep up with Internet Explorer (IE) & Edge, claiming better [load times and battery life](https://www.microsoft.com/en-us/windows/microsoft-edge). As anybody who created websites back when you needed to support IE6, I still held on to a deep fear of supporting any version of IE, no matter how much Microsoft claimed to have improved it.

# IE11 and Edge Almost Fooled Me

After testing both IE11 and Edge on a Windows 10 machine, I was generally satisfied with their page load times and user interface, so I was thinking making my site work with IE wouldn't be so bad. Then I got heavy into [customizing my Jekyll-powered website](/blog/customizing-jekyll) and started to run into bug after bug in IE implementation of modern web standards. I thought one or two was a fluke, but after I hit #4 I realized that fully supporting IE11 with a modern website still required numerous workarounds.

# The Laundry List of Modern IE/Edge Issues

## 1. IE will not animate table-row

If you are using the css table layout, then you can't animate the table-row elements, instead you need to apply the animation to each table-cell element in the row. [Will not be fixed in IE](https://connect.microsoft.com/IE/feedbackdetail/view/917034).

## 2. IE incorrectly sizes img elements inside containing divs

With an img element inside a containing div that has a set with, IE doesn't scale the img to fill the div, instead overflowing it. This is corrected by setting the img width separately.

## 3. Edge animations can cause aliasing artifacts

Due to the way Edge display animations along with the TrueType fonts, text in the area around an animation can blur before, during, and after an animation in a non-predictable way. I found no great workaround for this.

## 4. IE11 doesn't animate on active selector

While other browsers correctly applied CSS animations when a button was clicked via the active selector, IE11 failed to do so.

## 5. Edge can't perform certain animations if a scaling has been applied

When using [flipclock.js](http://flipclockjs.com/), the animations failed on Edge if I applied a scaling to shrink the entire animation to make it responsive.

# It's 2016, why is it still this bad?

Somehow I knew at some deep level going into this project that I'd spend X amount of time making the site work perfectly on chrome/firefox/safari, and then I'd end up spending an additional X times 2 amount of time spending the site not look completely broken on IE/Edge. I had hoped that Microsoft had somehow learned from their mistakes and put some real effort into making their browser less of a nightmare to support, but that hope was short lived, smashed under bug of bug that Microsoft publicly acknowledged but felt no need to correct.

That's alright though, they've made their position clear and it makes my choice easier as well. For future projects, I will make it clear from the start that supporting the [shrinking pool of users](https://www.netmarketshare.com/browser-market-share.aspx?qprid=2&qpcustomd=0) who still use IE/Edge is not something I'm going to include as part of my standard estimates and that the time and hair-pulling necessary to ensure IE/Edge compatibility will come at an additional price that hopefully makes it's a bad idea from a business perspective.
