---
title: "StickWars' Ninth Life"
layout: post
date: 2017-08-07 17:00
tag:
- iOS
- StickWars
- XCode
category: blog
image: /images/stickwars.jpg
description: "Dodging the death-blow of iOS 11's 32-bit crackdown"
---
First released in back in early 2009, [StickWars](/projects/stickwars) is officially a very old game. Just looking at the [reviews](http://www.148apps.com/reviews/stickwars/) of version 1.1 made me feel like that time was decades ago, which is pretty close to being true these days.

The game in its current form is essentially complete, why mess with something so simple that just works? You sit down, flick some invading stick figures to their doom, and eventually deal with a few extra enemies and powers.

Because of this, the only updates to the game for the past 5+ years have been maintenance updates, fixing screen-scaling issues when Apple would release a new device with slightly different proportions, or the rare bug fix when an iOS update triggered something bad that caused excessive crashing.

## Apple the good cop

Up until this point, Apple has been amazingly supportive of legacy applications, obviously putting considering effort into not breaking old applications. While I don't directly see the work they are doing, I know they are doing it, because they keep updating iOS but StickWars continues to run just fine, year after year, with minimal intervention on my part.

My last version 1.8.9 was released Sept 19th, 2013, so we're talking about some serious backward-compatibility work on Apple's part. That appears to have it's limits though...

## Apple the bad cop

Understandably, Apple can't keep working forever to keep abandoned apps running on the latest version of their OS, and put their foot down with [iOS 11](https://9to5mac.com/2017/06/06/ios-11-32-bit-mac-app-store-64-bit/).

Since the iPhone 5S, released in 2013, iPhones have been equipped with 64-bit processors, and all new and updates to apps were built to run on that newer 64 bit architecture. The only apps in the store which are still 32-bit are those which have not been updated since 2013 or earlier, and Apple will prevent those apps from being purchased & installed with the release of iOS 11, planned for sometime in 2017/early 2018.

The impact of them forcing apps to either be updated or be removed from the app store & installed devices is potentially significant, with some stats published by [Business Insider](http://www.businessinsider.com/apple-ios-11-32-bit-apps-compatibility-2017-8):

> Well, it turns out that Apple may stop supporting nearly 200,000 apps come September. 

> According to Oliver Yeh, cofounder of app intelligence firm Sensor Tower, there are 187,000 32-bit apps still on the App Store, which equates to about 8% all iPhone apps (Sensor Tower estimated in March that there are approximately 2.4 million apps on the App Store). 

## Soooo this 64-bit thing is easy to fix, right?

The answer is, maybe. The reason you can't just open up a project that hasn't been touched in three years, hit compile and expect it to pop right up is the tools you are using to build that project may have changed since then.

This is especially true with Xcode, the IDE built by Apple that you basically must use to do iOS development. The Xcode of today is fantastically easier to user and a better experience than what I remember from years ago, but it's still a learning curve to figure out how new things work.

The real issues pop up when actually trying to run the app when built for 64-bit, and these were obvious right off the bat: the app would crash instantly as soon as it tried to draw anything with OpenGL. Uh oh.

## Converting to 64-bit

Luckily Apple providers a dummy proof list of [common steps](https://developer.apple.com/library/content/documentation/General/Conceptual/CocoaTouch64BitGuide/ConvertingYourAppto64-Bit/ConvertingYourAppto64-Bit.html) to take to get your app ready for 64-bit, and for the biggest bug in StickWars the first header was the right answer:

> Do Not Cast Pointers to Integers

Now I wasn't the the one who wrote this code that did all these interesting things with OpenGL, back when I was creating StickWars I used a wonderful open source library called [cocos2d-iphone](https://github.com/cocos2d/cocos2d-iphone-classic). In fact my name is right at the top of that projects [donors](https://github.com/cocos2d/cocos2d-objc/blob/v3.5.0/DONORS) list, as StickWars was the first app using the new (at the time) library to hit #1 paid app in the App Store.

The problem was that library had evolved away into something completely different, it has since been updated by 3 major versions, renamed to cocos2d-objc, and then abandoned two years ago. StickWars was still running on v0.8.1, so it was on me to patch it and get that version running in a 64-bit app.

## Crashy McCrashFace

Taking a look at the stack trace, StickWars was crashing whenever it tried to paint a texture atlas with OpenGL. This line is kind of important, if you just comment it out (yes I tried that) than no game characters show up, all you get is the background, sounds, and music. You can still throw the enemy stick figures around and play the game, you just can't see anything. Not very fun.

So I took a close look at the offending method:

`/cocos2d/TextureAtals.m`
```objc
-(void) drawNumberOfQuads: (NSUInteger) n
{	
#define kPointSize sizeof(quads_[0].bl)
	glBindTexture(GL_TEXTURE_2D, [texture_ name]);
	
	int offset = (int)quads_;

	int diff = offsetof( ccV3F_C4B_T2F, vertices);
	glVertexPointer(3, GL_FLOAT, kPointSize, (void*) (offset + diff) );

	diff = offsetof( ccV3F_C4B_T2F, colors);
	glColorPointer(4, GL_UNSIGNED_BYTE, kPointSize, (void*)(offset + diff));
	
	diff = offsetof( ccV3F_C4B_T2F, texCoords);
	glTexCoordPointer(2, GL_FLOAT, kPointSize, (void*)(offset + diff));

	// CRASHING HERE with EXC_BAD_ACCESS, which means a pointer was bad, or pointing to something dealloced
	glDrawElements(GL_TRIANGLES, n*6, GL_UNSIGNED_SHORT, indices_); 
}
```

After reviewing Apple's conversion guidelines, the fix wasn't as challenging as I thought it may be:

Fix `int offset = (int)quads_;` to `uintptr_t offset = (uintptr_t)quads_;`, and voila! No more crashes.

## Almost there...

With the crash fix, I ran through the game and noticed all the particle effects were way off. I suspected a similar issue, and sure enough the library had been using the CGPoint to store point locations. Apple warned to check CGPoint in their conversion guide as it had converted from 32 to 64-bit, so again I went hunting. Sure enough, I found where the library was pushing a CGPoint directly to an OpenGL function:

`/cocos2d/ccTypes.h'
```objc
#define ccVertex2F CGPoint
```
Changed to
```objc
struct CGPoint32Bit { 
    float x; 
    float y; 
}; 
typedef struct CGPoint32Bit CGPoint32Bit; 
#define ccVertex2F CGPoint32Bit 
```

Along with a minor fix to `/cocos2d/PointParticleSystem.m`, and that was it! A updated the AdMob library in the lite version and prepared the update.

## Total time to fix

I didn't zealously track my time like I do for my client work, but I estimate the total time spent getting the update pushed out to be about 10 hours. A lot of secondary tasks end up eating up time more than you may expect:

* Creating screenshots. Apple has has strict requirements on [acceptable screenshots](http://help.apple.com/itunes-connect/developer/#/devd274dd925), so if you don't have current screenshots for the app store you'll have generate new ones. Additionally, if you don't own a current iOS device, you'll need to use the simulator to take the screen shots (a major PITA).

* Updating project metadata. Apple has improved how Xcode manages the metadata, but the combination of legacy and new settings led to a lot of tweaking until the project played with iTunes Connect nicely.

## Other barriers to updating

So when wondering to yourself 'why don't the devs for those 200,000 apps just update them before iOS 11 kicks them out of the store?', keep in mind what's needed to update each one of those apps.

* A Mac running OS X. It's a very expensive time to be an Apple developer who wants to run on modern hardware. The current generation of mid-range Macbooks are not great for development, and try not to gag at the cost of the lowest-end [15" Macbook Pro](https://www.apple.com/shop/buy-mac/macbook-pro/15-inch).

* A dev on hand to pick up the project. I wrote StickWars from scratch, so even though it was ages ago I still have an idea how I structured everything overall and could be productive quickly. When picking up a project written by a different dev, this can be a good or bad time based on how easily you can understand what they did.

* An incentive to keep the app alive. StickWars is still in the top 150 of paid arcade/action games in the US. It's not a fire hose of sales, but enough that it's definitely worth the effort to keep alive. Plus with 8% of the iPhone apps leaving the store with iOS 11, there may be a bump from less competition?

## Say good-bye to your old (and probably forgotten) favorites

Most likely a lot of the 32-bit apps that haven't been updated by this point probably won't be. Even though you paid for them (many, many years ago), you will lose them soon when you update to iOS 11.

Take these last remaining months and rekindle your fun with those apps before they are gone forever. To find the apps which will be disappearing soon:

> Open **Settings**. Tap on **General**. Tap on **About**, and select **Applications**. The list under 'NO UPDATES AVAILABLE' are those 32-apps that will be going away soon enough.

Personally I'm going to miss [Robot Unicorn Attack](https://itunes.apple.com/us/app/robot-unicorn-attack/id374791544?mt=8) and [Galcon Labs](https://www.engadget.com/2009/10/03/galcon-labs-in-the-app-store-now/), and couple of the few games that I've never deleted since I know I may spin them up when bored on an airplane with no internet for hours.

P.S. Don't buy those games based on my recommendation, as I said they are probably going away soon.

