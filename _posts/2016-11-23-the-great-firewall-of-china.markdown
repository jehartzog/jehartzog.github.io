---
title: "The Great Firewall Of China"
layout: post
date: 2016-11-23 17:00
tag:
- Travel
category: blog
description: "A month struggling against the Internet Firewall of China"
---
I was lucky enough to be able to pay a 3 week visit to my in-laws living in China, and what an experience it was. While the entire trip was a nonstop adventure into new culture, food, and family, I was surprised at how much the internet in China had been locked down since I lasted visited in 2007.

### What is the Great Firewall (GFW) of China?
If you haven't heard about it before, the [Great Firewall of China](https://en.wikipedia.org/wiki/Great_Firewall) is a system put in place by the Chinese government to restrict and monitor the internet usage of Chinese citizens. Think of it like a parental filter running on your wifi router, except this one covers the entire country.

### Blocking out the Western World
Once I arrived at China, I was shocked at how nearly every source of communication and news that I used on the U.S. was blocked in China. While I expected the firewall to block Facebook and other social media sites, I found that almost every major english language website was blocked or unavailable. Here is a partial list of sites I tried to use that were [blocked in China](https://en.wikipedia.org/wiki/Websites_blocked_in_mainland_China):

* Google
* Facebook
* YouTube
* Twitter
* GitHub
* The New York Times
* Vimeo
* BBC

### How to break the Internet
You may look at this list and think that you could just find alternate sites and still get along find, but you will find the way the GFW works ends up breaking a lot more sites and services than you think.

Rather than immediately blocking requests to those sites, the GFW instead silently drops all packets going to the IP addresses that all those domains point to. This has a few important implications:

1. Since it blocks any and all requests going to a wide range of IP addresses, a lot of sites and services that are otherwise not blocked will silently fail if the rely on any services provided by a blocked company.

   You may have no idea how many websites rely on code provided by [Google CDN](https://developers.google.com/speed/libraries/) until that CDN is blocked and the site loads without any CSS or Javascript that it expects. About [250 million people](http://mashable.com/2010/12/08/facebook-connect-stats/#5.ykkkCX.kqk) (as of 2012) use Facebook Connect for user login, which will silently fail behind the GFW.

2. When you are trying to use a service that is either directly or indirectly blocked, it doesn't fail gracefully. Instead of receiving a failed request, portions of the service or application may load while waiting for a response that will never come. Trying to use these services ends up being a frustrating battle of figuring out what portions of an application will work.

   When trying to use Dropbox to upload my photos, I was able to browse my Dropbox files and folders, but any attempt to upload would time out.

### What's a Westerner To Do?
It's no great surprise that despite efforts to clamp down on the Internet, people find ways to get around them. There are countless [VPN](http://www.pcmag.com/article2/0,2817,2403388,00.asp) services out there which provide a way to connect to the world outside the GFW. You can find a decent service for about $5 per week, and although you suffer from high latency and low bandwidth, it allows you to communicate with your friends and family back home.

### The VPN Crackdown
Just like any tool, a VPN can be used for both good and evil. While I used to let my family back in the U.S. know where I was traveling and pass along some pictures, it can also be used by criminals to hide their activities. It seems like the Chinese government decided they wanted to prevent any internet usage that bypasses the GFW and officially [banned the use of VPN's](http://www.cnbc.com/2017/01/24/china-cracks-down-on-vpn-that-help-people-getting-around-its-great-firewall.html).

## Big Brother is Watching
In the U.S. we are familiar with the idea that IP addresses can be tracked to the internet service provider (ISP) who can identify individuals based on who pays the internet bill. But when you start looking at open WIFI hotspots, pre-paid cell phones with data plans, and many other convenient ways to access the internet you suddenly have countless ways to access the internet without easy tracking of online activity with an individual.

It took me a while to realize this, but government regulations in China have steadily removed every possibility of somewhat-anonymous internet usage, making it nearly impossible to go online without the government knowing exactly who is behind the keyboard.

### No open WIFI or SIM cards for Foreigners
When I last visited China in 2007, I was able to purchase a pre-paid cell phone to make local and international calls. When I tried to purchase a cell phone or SIM card on my recent visit, every vendor refused to sell to me as I only had a passport for identification. Turns out regulations required a Chinese citizen identification card, and I wasn't the [first foreigner to be surprised by this](http://www.gokunming.com/en/forums/thread/9292/no_sim_cards_for_foreigners).

After I found out I was unable to purchase a Chinese SIM card, I starting hunting out open WIFI networks, available at many hotels, restaurants, and public attractions. Imagine my surprise when I learned that every open WIFI hotspot has built in security that requires login via a Chinese phone number before access is granted.

### The Circle of Tracking is Complete
Looking at the combination of all these restrictions, you can see how the Chinese government has systemically eliminated any potential for legal internet usage without constant attribution to the individual. In doing so, they also made it nearly impossible for foreigners to obtain any internet access without the aid of a friendly citizen who then carries the risk of that usage.

### Expatriate Communications from China
A have a few friends from the U.S. who currently live in China, and I wonder how they carry on under the weight of all these internet regulations. With the recent outlawing of VPN's, any person in China has almost no legal methods for communicating with their friends and family back home. The best option they have is to ask their friends to install the government-sanctioned [WeChat](https://en.wikipedia.org/wiki/WeChat) application which [routes all communications through government filters and logs](https://qz.com/848885/china-is-censoring-peoples-chats-without-their-even-knowing-about-it/).

### So What?
Despite being familiar with the GFW, I was still surprised as the expansion and subsequent effects on all communication within China. I believe the bringing awareness of what is going on can help guide opinions of how we want to affect policy here in the U.S. We are all familiar with the constant debate in the media about the struggle between privacy advocates and the authorities protecting us against criminals, but rarely are we exposed to the real-life effects of a culture where that balance is so drastically different than here in the U.S.
