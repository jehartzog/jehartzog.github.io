---
title: "Meteor Galaxy AutoScale"
layout: post
date: 2017-09-21 17:00
tag:
- Meteor
- Galaxy
- NodeJS
- PhantomJS
- WebdriverIO
- Skoolers
category: blog
image: /images/meteor-logo.png
description: "When no other tools will work, duct tape and WD-40 to the rescue."
---

I've released the public version of [galaxy-autoscale](https://atmospherejs.com/avariodev/galaxy-autoscale) which helps to auto-scale and provide cost savings for hosted Meteor apps.

If you're shopping around on how to host your upcoming Meteor app, the one host you'll sure to know about is [Meteor Galaxy](https://www.meteor.com/hosting), created by [MDG](https://www.meteor.io/), the group that actually created Meteor.

# Premium cost for DevOps time savings

At [~$40/month](https://www.meteor.com/pricing), you are paying almost 10x the cost of a [AWS t2.nano](https://aws.amazon.com/ec2/instance-types/t2/) instance which have comparable performance. The T2 instances are actually superior in most cases as they offer [burst-able performance](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/t2-instances.html) over a 24 hour period, which is incredibly helpful if most of your customers are in the same time zone.

## What Meteor Galaxy provides

What are you getting in return for this premium price on server resources?

1. Automated deployments of updated app versions with zero-downtime rolling restarts.

2. Integrated [APM](https://blog.meteor.com/introducing-galaxy-professional-built-in-apm-5e063839a4aa), the essential monitoring suite for Meteor apps.

##  What Meteor Galaxy takes away

Here are the essential features you may assume would be part of the hosting service but you actually **lose** by using Meteor Galaxy.

1. Any type of alert notification, including container health, maintenance restarts, CPU/memory usage.

2. Auto-scaling number/size of containers based on configurable rules.

3. Stable uptime of your app containers (more to follow on this, maybe...).

# Band-aid where it's easy

During the process of seeing a [full production load](/blog/scaling-with-meteor) for the first time, I initially had to add quite a few containers to handle 200+ concurrent users. At one point I was running 6x compact pro containers just to ensure everything was far away from limits. Left at that level, our hosting cost would have been a solid $198/month, not something sustainable for such a small customer base.

The first place to help with this is just took look at our traffic, all of our users are on the US east coast, so our entire traffic happens during the same time period each day. It also varies moderately from day to day, so we want some easy to way have the right number of containers running without having to keep a human eye on these graphs 24/7.

![hourly users graph](/images/hourly-users-graph.png "Hourly Users Graph")

After [searching](https://forums.meteor.com/t/galaxy-auto-scaling/22221) and [searching](https://forums.meteor.com/t/auto-scaling-on-galaxy/33676) and finding nothing but feature requests followed by +1 comments, I realized was going to have to roll my own solution.

It took me less than a days work to write a [simple script](https://github.com/jehartzog/galaxy-phantomjs-autoscale) that runs on NodeJS that uses PhantomJS and WebdriverIO to scrape the needed figures from the Galaxy app dashboard, and click 'up' or 'down' to adjust the number of running containers. Definitely not my proudest bit of work, but it got the job done and didn't suck up a lot of time.

I set it up to run on a t2.nano EC2 instance with crontab and voila, I had the number of containers smartly adjusting based on the number of connections coming to my app.

![autoscale graph](/images/autoscale-graph.png "AutoScale Graph")

# Sharing a used band-aid?

Since I saw so many people looking for a Galaxy auto-scaling solution, I'd thought I package my little script up in case anybody else wanted to use it.

I repackaged it as a [Meteor package](https://atmospherejs.com/avariodev/galaxy-autoscale) and [posted it](https://forums.meteor.com/t/meteor-galaxy-auto-scaling-package/39400) to the forums. The response was as expected, some people half-smiling at such a brittle and janky approach, but most acknowledged it at least was a solution given the current lack of other options.

While I'm hoping adding features make that package entirely pointless sometime soon, at least it's a solution for now, or until it's time to move away from Meteor Galaxy all together.
