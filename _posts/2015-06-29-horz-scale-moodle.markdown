---
title: "Auto-Scaling Moodle Architecture on AWS"
layout: post
date: 2015-06-29 17:00
tag:
- PHP
- Moodle
- MySQL
- Website
- LAMP
- AWS
- EC2
- Git
image: /images/moodle-logo.png
category: blog
description: "Building a horizontally scaling Moodle server on AWS."
---

## The long term cost of getting started quickly

The TutoringZone website grew out of a sudden need to create an online delivery platform for tutor videos, and ease of creation was the most important criteria at the time. This lead to all server components being run on a single EC2 instance, a Bitnami image that was pre-loaded with a Moodle installation.

As the site matured and traffic picked up, the EC2 instance began to crawl under the combined load of the database, webserver, and static file delivery all running on the same VM. In order to reduce the >10 second load times, the admin vertically scaled to a more powerful EC2 instance until latency came down. While this solved the performance issue, vertical scaling comes a few major downfalls:

#### 1. Vertical scaling is expensive
 * In order to serve peak usage, the EC2 instance was scaled high enough that the AWS charges were **over $300 per month**.

#### 2. Vertical scaling is often manual and involves downtime
 * The admin had to predict when load would be high, and scale up the instance before hand to prevent causing a short outage by trying to scale during peak usage. When usage fell back down, he had to manually scale down the instance to reduce charges.

#### 3. Vertical scaling has an upper limit
 * The admin was already using the third highest EC2 instance to keep latency down, meaning if anything went viral for the business, the website was going down.

## The solution - horizontal scaling

By breaking up the server into discrete components, you can allow for better management of the individual components and cost effective scaling. Additionally, you can place a load balancer in front of the web server to share the demand. While there is not a step-by-step guide on how to do this for Moodle, there are enough guides on steps to do this for any LAMP style server.

While planning out the work, I drafted the diagram below which showed the end state of the new server.

![TZ AWS Scaling Layout](/images/tz-aws-layout.png)

## Issues to overcome when scaling Moodle horizontally

#### 1. The Moodledata directory
 * Moodle requires access to a single data directory to store its cache, static files, and other components. To ensure each separate webserver serves the same data, you need to decide on a method to synchronize this folder between the multiple webservers.
 * The solution I decided on was running a small EC2 instance running a NFS server to host this Moodledata directory, which was mounted by each webserver. This was straightforward to set up and has performed well.
 * Once AWS releases [EFS](https://aws.amazon.com/efs/) in the US-East area, I plan to migrate to use the managed service, providing automatic maintenance and backup of the NFS server.

#### 2. User session data
 * Session data for each user needs to be consistent even when running multiple webservers. This can be done by creating a shared session data cache, or by ensuring users are routed to the same webserver for the duration of their session.
 * The AWS Elastic Load Balancer server has simple option to enable 'sticky sessions' to insert a cookie to ensure users are routed to the webserver with their session. I decided on using this feature because of the simplicity of setup and acceptable performance.

## End result

After setting up AWS Auto-Scaling with the new Moodle server setup, we had a better performing server that would automatically scale with usage that benefited from the perks of AWS services (RDS auto updates and backups).

In addition, by bringing to the average AWS costs down to $50 per month, TutoringZone ended up saving **$3,000 annually** for a project that took less than 25 hours from start to finish.
