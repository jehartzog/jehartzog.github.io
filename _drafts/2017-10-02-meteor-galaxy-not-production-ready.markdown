---
title: "Meteor Galaxy is not Production Ready"
layout: post
date: 2017-10-02 17:00
tag:
- Meteor
- Galaxy
- NodeJS
- Skoolers
category: blog
image: /images/meteor-logo.png
description: "Three prime-time outages in six months of production."
---

Despite the [10x cost premium](/blog/meteor-galaxy-autoscale), I wanted to enjoy my hosting experience with Meteor Galaxy, I really did. I knew my [app](/projects/Skoolers) was a perfect fit for them, with something around 1000 daily users max, I could use the benefits of their managed hosting without worrying about staggering costs as I tried to scale

I started off with a small audience from May to Aug 2017, giving me time to optimize my app and remove all [bottlenecks caused by app code](/blog/scaling-with-meteor). The full audience hit the app in September, allowing me to see how it did against 1000+ daily active users, and I was glad to see the app handling everything as well as could be expected, managing to support that load with about 1 CPU and 1 GB of memory.

### Meteor Galaxy support was responsive, polite, and professional

Before getting into all the negatives, I do want to share that the Meteor Galaxy support service was generally very professional, responding within 6 hours for all initial tickets, and letting me know when more time was needed for a more detailed response.

## Six months of hosting on Meteor Galaxy

Unfortunately these past six months have also exposed my application to three different Galaxy caused outages in my app, causing a serious lack of confidence in the seriousness as a production hosting provider. Through all of the outage, the response was consistently unacceptable as a professional hosting company for these basic reasons:

1. The [Galaxy Status](http://status.meteor.com/) never changed from green, nor sent an alert to subscribers.

2. In some cases, Galaxy caused an outage or period of extreme latency that was never reported on forums or their status page, merely acknowledged privately back to me after continued questions through their support system.

3. The response time to acknowledge these smaller scale outages took **13 days** to provide a confirmation of a Galaxy-caused outage.

For all the times listed, I am referring to US East Coast.

### Outage #1 - 27 June, 6am - 10am

This was a huge one, approx 4 hours of outage until MDG finally responded with a solution.

Pingdom sent an alert that the site was unreachable, and after I woke I saw [others were having the same issue](https://forums.meteor.com/t/contain-health-checks-fail-on-galaxy-deploy/37403/29?u=avariodev). Multiple hours after the outage began, Galaxy status still indicated all green with the only posts being from affected customers. Finally a forum post went up on the above thread, but no update went out via the official Galaxy Status system.

They ended up writing a detailed [after action report](http://status.meteor.com/incidents/tf630kbt1x2n) which was the right thing to do in this case. They listed the steps they took to prevent this from recurrence, so while overall their response in-situ was extremely delayed, they eventually did the right thing.

I would have hoped they would address lack of any updates on the Galaxy Status page until the day after, but thought that may be part of their fixes to their maintenance schedule.

### Outage #2 - 5 September, 3pm - 3:30pm

This one was a shorter time duration but still very uncomfortable. They ran a maintenance update at 3pm which caused 30 minutes of disruption to all my running containers. Latency for methods, pubs, and connections rose to 10+ seconds, and in many cases the containers were completely unreachable.

APM graphs coverage the outage
![galaxy outage 5 sept](/images/galaxy-outage-5-sept.png "Galaxy Outage 5 Sept")

This being prime-time for my app, clients noticed right away and contacted me, and I started desperately spinning up additional containers and up-sizing them while trying to understand what was going on. After about 30 minutes latency fell back to normal and I was left wondering what happened, worried my app code was flawed in some way I didn't understand.

After six hours, I got a response on the ticket I opened saying that a normal container maintennace restart occured during that time. I pointed out the service logs were blank for the entire time period in question. I got a response 24 hours later from another rep saying they were taking this to their engineering team to take a look and would get back to me.

**13 days later**, on 19 September, I received the following response:

> Thanks for your patience here; I received a full debrief from our engineering team about this. In short, the increased latency you observed was our fault, and we apologize for this.
> 
> What happened was that Galaxy changed the EC2 instance type we use for hosting application containers. Because of this change, Galaxy relaunched every running container, for every user.
>
> The mass container relaunch temporarily overloaded the EC2 instances that host application containers, resulting in the increased latency you observed.
>
> In hindsight, it would be have been better to complete this work during a scheduled maintenance window; testing in our staging environment, as well as smaller regions, made us believe the impact would be negligible - but we were mistaken, and the latency you observed was the result. Again, we apologize for the inconvenience. I hope this explains what happened, but please let me know if there's anything else I can answer.

While I was very satisfied with receiving a response, I was bothered by a number of ways in which this situation was handled.

- No public acknolwedgement of this outage. Unless this truly only affected one customer (unlikely), it should have been posted to their status page along with an announcement.

- 14 days from opening of ticket to confirmation of outage. I get them I'm a small customer, but I'm also a small customer with AWS, and at least when their customers get unexplained multi-second latency, they will be sure to pay attention to it.

### Outage #3 - 3 October, 6:22pm - 6:35pm

With this outage being recent, I don't yet have confirmation that this was actually a Galaxy caused outage, so it's just my suspicion for now.

At 6:21pm, Meteor Galaxy replaced my running container as part of a maintenance event, this is common and happens without incident multiple times per day. However, the container that started up to replace it (`qzffh`) was deeply flawed, CPU pegged at max right away. Unfortunately it was responsive enough to pass the health checks, so Galaxy killed the old container and the new one was left serving web traffic.

Latency quickly rose to 5+ seconds for all subscriptions and method calls, and while Pingdom alerts me on a complete outage, something like the above latency requires better monitoring and alerts to let me know that something is going wrong.

After 8 minutes my client called to ask about general slowness. In response I spun up new containers and killed the flawed one, which restored the app to normal.

Galaxy service logs for the time in question
```
m28br 2017-10-03 18:15:44-04:00 The container is being stopped to scale down the number of running containers.
m28br 2017-10-03 18:16:17-04:00 Application exited with signal: killed
qzffh 2017-10-03 18:21:18-04:00 Application process starting, version 189
t24kk 2017-10-03 18:21:56-04:00 The container is being stopped because Galaxy is replacing the machine it's running on.
t24kk 2017-10-03 18:22:29-04:00 Application exited with signal: killed
0w5em 2017-10-03 18:32:10-04:00 Application process starting, version 189
3qdq2 2017-10-03 18:32:22-04:00 Application process starting, version 189
1fcej 2017-10-03 18:34:56-04:00 Application process starting, version 189
qzffh 2017-10-03 18:36:30-04:00 The container is being stopped due to a user kill request.
qzffh 2017-10-03 18:37:02-04:00 Application exited with signal: killed
```

APM graphs
![galaxy outage 2 oct](/images/galaxy-outage-3-oct.png "Galaxy Outage 3 Oct")

While I freely admit it's possible my app code somehow caused this flawed container, I consider that unlikely as I've never seen this type of behavior before, and my past experience with Galaxy maintenance restarts having unintended side effects. I've moved all cron and batch processing jobs to a cheaper AWS EC2 instance, so the only thing the webserver should be doing is client connections, delivering assets, pub/sub of collections and methods.

Another possible issue is database performance, but all stats there were normal, no excessive page faults or query latency.

The deeper issue is the lack of any sort of alert system that can let me know when average method and pub/sub response time rises above 500ms, a clear indicator of something going wrong. It's trivial to send this alert to my high priority slack channel, which can send me a push notification and let me try to fix things before my client has to give me a ring.

## Shaken Confidence

After this six-month run with Meteor Galaxy, it looks like it's unusable as a long-term provider for our app. While I'm a huge fan of the deep Meteor integration and managed app deployments, the lack of sustained low-latency availability and performance alert notifications mean I can never be sure if the application is really up and running as it should be.
