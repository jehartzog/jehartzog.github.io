---
title: "Skoolers App Details"
layout: post
date: 2017-10-02 17:00
tag:
- Meteor
- NodeJS
- Skoolers
category: blog
image: /images/skoolers-logo-200x200.png
description: "A breakdown of generic "
---
This is a portion of my [Scaling with Meteor](/blog/scaling-with-meteor) post broken out for readability. 

For other developers helping to plan out whether Meteor can support their apps, I lay out the generic requirements of the [Skoolers Tutoring](/projects/skoolers) app that I created, along with some hosting details.

## Meteor version and front-end

My app was originally started with Meteor 1.3 and has been updated to keep in sync with the latest released version. I use React as the front end, and do not perform any server-side rendering.

## Hosting provider

I used [Meteor Galaxy](https://www.meteor.com/hosting) for my webserver and a [mLab](https://mlab.com/) shared MongoDB cluster. Galaxy was very easy to get set up and running, and I would recommend for anyone starting out with their first Meteor product but I had some issues over a few months of using them. mLab was awesome, their support was fantastic the single time I ever needed it, and the price was just right.

## Pubs

With about 10 publications to every student depending on their current page, all of which are important to be real-time with low-latency. While I carefully limit the number of documents provided in these publications, since they are user-provided posts/questions/etc, the overall data transferred to each client can be over 100 KB. A non-exhaustive list of some of the data includes:

 - All the current course offerings for their school
 - A list of all the courses each student is enrolled in
 - A list of the paginated wall posts for a course they are looking at
 - A list of all the videos available for a course
 - A list of all the scheduled events for a course
 - A list of all the files available for download for a course
 - A list of all the quizzes available for a course
 - A list of all the questions available when taking a quiz

## Methods

The app also has a number of Meteor method calls which are called very often to keep track of user progress. At peak load I end up getting a method call which results in some sort of database write every ~2 seconds.

## Bundle size

When Meteor 1.5 released I used their new dynamic imports feature along with React Loadable to [trim the bundle size](/blog/code-splitting-with-meteor-dynamic-imports-and-react-loadable), resulting in a gzipped main bundle size of ~470KB. Not as trim as it could be, but considering my traffic is primarily returning clients and I don't run constant updates to the site, the time investment to further trim the bundle wasn't worth it.

## Traffic schedule

All my traffic is student based at local universities, all in a single time zone and with regular schedules. The first traffic starts up around 8am, rising to a plateau that lasts from 12pm to 12am, with traffic dropping to zero around 3am.

The traffic is also strongly correlated with upcoming exams, which can double the total DAL (daily active users) from one day to the next. I don't desire to follow this exam schedule closely, and wanted to build a system that can automatically adjust for this large variance in traffic.

## Interactive wall

This is one of the data-heavy features we use, receiving hundreds of posts per day which are then published to the entire audience. It is features like this where Meteor really shines, allowing real-time, efficient updates.

The posts themselves are entered using a [Froala](https://www.froala.com/) RTE, and saved as HTML. The server also handles things like providing temporary S3 tokens for users to post images/files/videos to S3 and automatically link to them inside the RTE.

![skoolers wall](/images/skoolers-wall.png "Skoolers Wall")

## Practice quizzes

This allows the tutors to create tailored quizzes using multiple/single choice or fill-in-the-blank questions. Students can then practice these quizzes and review their results. As a student is taking a quiz, each answer they provide as type type/click is submitted via Meteor method to ensure their progress is saved.

These quizzes turned out to be much more popular than anticipated, but Meteor handled the unexpected load just fine.

## Enrollments

As a paid product, the app is responsible for managing which students have been enrolled in specific products, and providing the correct publication data and routing.

## Logs

I care about tracking how users are interactive with various features on the site, so I want to keep track of which products they are downloading, and what videos they are actually watching. These videos are the primary product of the site, so accurately recording this information is key to evaluating which videos are successful.

# More about Skoolers scaling

To read more about how this app performed under real production load, continue with the [Scaling with Meteor](/blog/scaling-with-meteor) post.
