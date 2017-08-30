---
title: "Creating StickWars - A Spring Break Learning Project"
layout: post
date: 2009-03-01 17:00
tag:
- iOS
- Games
image: /images/stickwars.jpg
category: blog
description: "An Objective C learning project, StickWars grew to become a worldwide phenomenon"
---
## Started in a Spring Break Beach House

Development of StickWars started during spring break of 2009 while I stayed with college friends at a beach house. The evenings were spent with friends, but the days were wide open and so I decided to start on a new project. I had recently purchased an iPhone 3G and was hooked on all the games I could find for it, but I was surprised at the limited selection.

## The Early Days of the App Store

The Apple App Store had been released just a few months ago and although new apps were constantly being released they were often poorly written and lacked useful functionality. The best game I found at the time was [Notecard Defense](http://hijinksinc.com/2009/03/13/sneak-peek-notecard-defense/), but there was still a lot of progress to be made.

I was in my senior year completing my Computer Science degree at the time and thought I could make a better game, so I set out to do it. I learned photoshop and painstakingly hand drew all the stick figures and gradient art, and purchased a small set of sound effects to add. It was no small feat to allow the game run smoothly with over 25 animated figures on the screen on the iPhone 3G's 412 MHz processor and 128 MB of RAM, but luckily I had some outstanding libraries to assist me.

## Open Source to the Rescue

Unlike the existing apps on the store, whose authors often had to assemble their own functions for OpenGL, physical simulation, sound effects, and more, I sought out and located open source libraries which streamlined the development process. While they were still in their infancy, filled with bugs and void of most documentation, they still provided an advantage over starting from scratch.

I started with a library called cocos2d-iphone (now called [cocos2d-objc](https://github.com/cocos2d/cocos2d-iphone-classic)), and it provided a great starting point and allowed me to focus on game design and performance. By integrating [Chipmunk2D](https://chipmunk-physics.net), a battle tested open source physics library, the enemies in StickWars would naturally followed your finger tosses around, realistically falling and colliding with one another.

After StickWars skyrocketed in popularity, I was able to [contribute](https://github.com/cocos2d/cocos2d-iphone-classic/blob/v2.2/DONORS) back to the project on which my game was built, and I was forever sold on the merits of open source development.

## Three Weeks to the App Store

After three intense weeks of development, the first version of StickWars was ready for the App Store. Although playable, it only featured a single enemy which grew faster and more numerous as the levels progressed. It had no background music, simple artwork and limited gameplay. What it did have was an incredibly simple and responsive play mechanic that allowed you to naturally toss around invading stick figures with your finger at ease, something unique on the App Store at the time.

Within a week of the first version going live, StickWars had thousands of downloads every day, and I quickly realized I was on to something big. I dropped everything else I could (technically I was still enrolled full time in classes), hired a friend to assist with new graphics, and began developing around the clock to push bi-weekly updates.

## Six Months of Mayhem

While simultaneously graduating from college and starting my career in the Navy, I was pushing out updates to StickWars every 2-4 weeks, until finally after 6 months the current version of the game was primarily complete. It was at that point that I took a back seat to allow partners to take over development of the StickWars sequels.
