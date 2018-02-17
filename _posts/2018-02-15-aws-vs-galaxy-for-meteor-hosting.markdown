---
title: "AWS vs Galaxy for Meteor Hosting"
layout: post
date: 2018-02-15 17:00
tag:
- Meteor
- NodeJS
- Skoolers
- MongoDB
category: blog
image: /images/meteor-logo.png
description: "The verdict is clear, AWS absolutely dominates and at a lower price."
---

After 6 months of hosting on Galaxy with multiple [host caused outages](/blog/meteor-galaxy-not-production-ready), I was willing to put in the effort of transitioning to AWS. Nothing is more stressful for a DevOps provider than to have his apps drop offline for no good reason, and not have any alerts to warn of issues before Pingdom tells you that your website is timing out.

## Time for a change

After deciding I couldn't stick around and wait for Galaxy to fix itself, I started looking for alternatives. I was intrigued by [NodeChef](https://www.nodechef.com/), but after the negative experience with Galaxy I was wary of trying a 'specialty' hosting provider over a battle-tested solution. I had experience with AWS in the past for hosting LAMP stack application, so I started the process of using [MUP](http://meteor-up.com/) to get my app up and running on AWS EC2 instances.

## Performance, Performance, Performance!!!

I know that the Galaxy group invested a lot of effort into building a scalable Meteor hosting solution, but **it is way too slow**. I was surprised when I first fired up APM on Galaxy and saw 400ms pub/sub response times, which are acceptable but not great. When you add that delay to the typical Meteor delay of downloading/processing the initial bundle, you're talking about a good bit of time before a useful render.

After I while I figured this was just a Meteor thing and I should accept that. **I was wrong**, and AWS showed me how performant Meteor can truly be.

I had some Galaxy performance data from my [scaling with Meteor](/blog/scaling-with-meteor) post, and I was able to compare it to my new AWS setup under a nearly identical customer load.

### App on Galaxy
![skoolers-peak-galaxy](/images/skoolers-peak-post-oplog.png "Skoolers Peak on Galaxy")

- 3x compact containers (0.5 ECU, 512 MB each).
- ~$120/month.

### App on AWS

![skoolers-peak-aws](/images/skoolers-peak-aws.png "Skoolers Peak on AWS")

- 2x t2.micro containers (1 vCPU, 1 GB each).
- ~$50/month (2x t2.micro + network load balancer). 

### How AWS dominated Galaxy

- Speed.
  - I'm getting 10x faster response times on AWS than on Galaxy while the webservers are at similar CPU/memory conditions.

- Simplicity. 
  - I don't need to auto-scale. Because of how Galaxy is built, Compact containers are hard-capped at ~15% CPU as shown in APM. This is a serious problem if something eats up CPU usage suddenly as delayed methods/publications cause a cascading effect due to how Meteor waits to ensure operations are completed in order.
  - On the other hand, AWS allows t2 instances to burst above baseline for a sustained amount of time, allowing the app to stay responsive under unexpected loads. 

- Metrics.
  - Galaxy has zero reporting or alerting capabilities. Enough said there. 

- Stability.
  - While I'm less than 2 months into AWS, already I've had a much more stable hosting experience. I don't get the constant maintenance restarts that sometimes cause latency and other unexpected issues that came with Galaxy hosting.

- Cost.
  - I'm paying less than 50% for AWS than what I did for Galaxy.
  - AWS does have a number of small charges that are hard to estimate, but overall it's still far cheaper than Galaxy.

## What I miss about Galaxy

Overall I estimate that I spent roughly 40 hours to patch/fix/build things that Galaxy provided for me. While the paypack period for this work was longer than it's probably worth, I now have a piece of mind allowing me to relax knowing AWS has my app up and running strong.

Here is a list of all the major features and compromises I had to deal with when leaving Galaxy:

### APM

There are a number of posts online about how to deploy your own APM server. NodeChef even provides a standalone [APM service](https://www.nodechef.com/docs/node/meteor-apm). I tried that out and was generally satisfied, but it didn't offer any alerts and only kept ~3 days of data at $10/month/server. I had some time to try out other solutions and ended up going with [Imachens/meteor-apm-server](https://github.com/lmachens/meteor-apm-server) self-hosted on AWS. It was a bit painful to get up and running, but the end solution gave me everything I wanted at reasonable hosting costs.

### SEO

This one kinda hurt for a bit. Right after switching from Galaxy, pages started to drop out of the Google index. I then created a [prerender.io](https://prerender.io) token and integrated [prerender-node](https://github.com/prerender/prerender-node), which was a quick integration, but I'm still experiencing difficulty getting all my pages back in the Google index.

In January Google released their new search console which gave me better information on why my pages were not being included in the index. Google reported 'Submitted URL not selected as canonical', but I'm still trying to figure out why Google is rejected the pages I provide in sitemap as non-canonical. More to do there.

### Zero-downtime Updates

The one super nice thing about Meteor was pushing and updating your app. You just pushed your app, and it handled updating the containers one by one with rolling restarts.

With my current setup I have two webservers running behind a load balancer. When I push an update, MUP updates server 1, then server 2. In order to prevent crashing from excessive RAM usage, [MUP](https://github.com/zodern/meteor-up/issues/827#issuecomment-366001159) stops the running container, starts a new one, runs npm install and starts up Meteor. This takes between 20-40 seconds, during which users connected to that server will see errors. I could write a script to take those servers out of the load balancer and add them in after MUP is finished, but this very brief downtime during updates is acceptable for now.

### Timezones

This one was unexpectedly a pain and kept messing up my scheduled cron jobs. Galaxy reads the environment variable `TZ` and sets the timezone appropriately. MUP doesn't address how to adjust server timezones, so it's up to you to do. In the end I ended up creating a `post.setup` hook in my mup config:

```js
module.exports = {
  ...
  meteor: {
    ...
    hooks: {
      'post.setup': {
      remoteCommand: 'sudo timedatectl set-timezone EST',
      },
    },
  },
};
``` 

### Meteor App Unique Naming

Another task that Galaxy performed for me that I wasn't aware of is ensuring that my Meteor containers all had unique app names. When I first set up MUP with my two webservers, the apps were both named in the MUP config like this:

```js
module.exports = {
  ...
  meteor: {
    name: 'webserver-production',
    ...
  },
};
```

Turns out that is a very bad idea, as Meteor works with MongoDB and the oplog in a way that depends on unique app names. I thought the server was running fine, but it turns out updates from one of my two webservers would show in the client UI but not be saved to the DB. No errors/warnings were thrown to alert me to any issues. I didn't catch this error in initial testing, but clients noticed it quickly and I was able to resolve it in an hour by ensuring each webserver had a unique name ('`webserver-production-one`', '`webserver-production-two`', etc...).

This wasn't listed anywhere in the [Meteor documentation](https://guide.meteor.com/deployment.html) or called out clearly in [MUP](http://meteor-up.com/getting-started.html). This was the single largest 'gotcha' that I experienced switching from Galaxy to AWS/MUP that negatively affected production operations. Luckily it was relatively minor and I was able to fix it quickly.

## Final Thoughts

I've held off posting my negative experience with Galaxy for a long time, because as a developer I've enjoyed working with Meteor and I intend on doing so again in the future. They've continue to push fantastic updates to Meteor and been focused on improving the platform while keeping in mind changes in the community as they go. But after putting in the time to create a Meteor app and transform it into a working production application, I feel strongly that Meteor is absolutely production ready, and Galaxy is not even close.

I've offered detailed feedback to the Galaxy support team and given all I can to try to help them improve what they offer, but while always polite they have always seem uninterested in major improvements.

While I've never spoken to anybody at AWS, it's because I've never needed to; their solutions just work, are incredibly reliable, and if AWS goes down, so does most of the internet so your clients won't really blame you. For my future projects I'll definitely be biased towards using the stronger 'general-purpose' cloud providers (AWS, DO, GCP, Azure) rather than specialty providers who wrap up the service with their own opaque framework.
