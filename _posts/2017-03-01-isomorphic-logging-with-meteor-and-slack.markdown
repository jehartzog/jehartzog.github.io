---
title: "Isomorphic Logging with Meteor and Slack"
layout: post
date: 2017-03-01 17:00
tag:
- Meteor
- Winston
- Logging
- Skoolers
- MongoDB
category: blog
image: /images/meteor-logo.png
description: "Using Meteor seamlessly log and alert in Slack from both client & server"
---
With the previous PHP/Moodle based solution, logging and alerts were piecemeal addons that didn't work well together, provided little useful information, and could not be used flexibly anywhere in the project. For the most part, I had to rely on customers sending me screenshots to see what was going odd, or browse hundreds of pages of messy Apache logs to pick out the one error among thousands that actually mattered.

With those lessons in mind, I wanted a simple but powerful logging solution for the replacement site, and using Meteor + some NPM packages, it turned out to be a breeze!

## TL;DR

With the end solution, I can call `logger.error('Ohnoes!');` anywhere on the site, whether in client or server code, and the function will end up running on the server, passing the event to all desired transports (Slack, console, DB) based on severity level.

When it posts to my Slack alert channel, I get a handy notification with formatted JSON data that I can glance at to decide if there is something I need to fix quickly.

## Setting up isomorphic logging function with Meteor

When I first started searching for previous work, I found [this post](http://www.east5th.co/blog/2016/07/04/winston-and-meteor-13/) that helped me decide how to start. I liked the idea of taking the same named function and exporting it different based on client/server environment, but I ended up with a somewhat different solution than what he laid out.

I added a few NPM packages and then created the server handler to pass log events to each transport.

`/server/logger.js`
```js
import winston from 'winston';
import 'winston-mongodb';
import { Slack } from 'slack-winston';
import { Roles } from 'meteor/alanning:roles';
import UserAgent from 'useragent';

let transports = [
  // API details here https://github.com/niftylettuce/slack-winston#usage
  new Slack({
    domain: Meteor.settings.slack.domain,
    token: Meteor.settings.slack.token,
    webhook_url: Meteor.settings.slack.webhook_url,
    channel: Meteor.settings.slack.channel,
    handleExceptions: true,
    humanReadableUnhandledException: true,
    level: Meteor.isProduction ? 'warn' : 'error',
  }),
  // API details here https://github.com/winstonjs/winston-mongodb#usage
  new winston.transports.MongoDB({
    db: process.env.MONGO_URL,
    collection: 'dev_logs',
    expireAfterSeconds: 60 * 60 * 24 * 30, // 30 days
    handleExceptions: true,
    level: 'verbose',
  }),
  // API details here https://github.com/winstonjs/winston/blob/master/docs/transports.md#console-transport
  new winston.transports.Console({
    prettyPrint: true,
    handleExceptions: true,
    humanReadableUnhandledException: true,
    level: 'info',
  }),
];

// We use a re-writer here to attach more detailed user information for all logs events, if available
const addUserInfo = (level, msg, meta) => {
  const newMeta = { ...meta };

  try {
    // If we are inside a pub/method/client code where Meteor.user() works and have a profile, log the info
    const user = Meteor.user();
    if (user && user.profile) {
      newMeta.userInfo = {
        name: user.profile.name,
        id: user._id,
        role: Roles.getRolesForUser(user._id),
      };

      // If we don't already have connection info but have user status using 'mizzao/meteor-user-status', use that info
      if (newMeta.ip == null && user.status && user.status.lastLogin) {
        newMeta.ip = user.status.lastLogin.ipAddr;
        newMeta.userAgent = UserAgent.parse(user.status.lastLogin.userAgent).toString();
      }
    }
  } catch (e) {
    // Do nothing, Meteor will throw an error cause we tried to call Meteor.user() outside of a method or pub
    // on server.
  }

  return newMeta;
};

// We are declaring 'logger' as a global variable to the entire server application
logger = new winston.Logger({
  transports,
  rewriters: [addUserInfo],
  exitOnError: false,
});
```

## What about the client code?

We now have a server wide `logger` object that we can pass events at will, but that is only half the battle. For my UI heavy application, the bulk of my code is React code on the UI side, and I want to be able to log events and send alerts for events which happen entirely on the client.

A few examples of where this is useful:

* 404 errors -  The router forwards to the error component but the error never touches the server.

* Logging user activity - Not shown in this post, I created a separate object called `activityLogger` that works exactly the same, but keeps a record of actions/edits to the site.

* Payment integrations - I integrated with [Braintree](https://github.com/braintree/braintree-web-drop-in) web drop-in, which has the client request payment authorization and then forward that on to your server. You want to be alerted of any errors in the client-side process.

## Setup client forwarding of log events with Meteor methods

When looking up how to accomplish this, themeteorchef.com had a great [post](https://themeteorchef.com/tutorials/building-an-error-logger) on how to do this. The length and complexity of their approach was a bit much, but it was a useful start on how to approach it.

I ended up creating a simple Meteor method to receive incoming log information and send them to my `logger` object, and attach a bit of extra user information if that was available.

`/imports/api/logs/methods.js`
```js
import { ValidatedMethod } from 'meteor/mdg:validated-method';
import { SimpleSchema } from 'meteor/aldeed:simple-schema';

// This may cause UserAgent to be included in main bundle, but it shown this way for readability
import UserAgent from 'useragent'; 

const addLogEntry = new ValidatedMethod({
  name: 'logs.addLogEntry',
  validate: new SimpleSchema({
    level: { type: String },
    message: { type: String },
    meta: { type: Object, blackbox: true, optional: true },
  }).validator(),
  run({ level, message, meta }) {
    // Don't do anything on the client for simulation
    if (this.isSimulation) {
      return;
    }

    // This is running in a method, so we have connection information we can attach to the log event
    const ip = this.connection.clientAddress;

    const rawUserAgent = this.connection.httpHeaders['user-agent'];
    const userAgent = UserAgent.parse(rawUserAgent).toString();

    // We don't want to delay processing other methods while this gets logged with all transports
    Meteor.defer(() => {
      logger.log(level, message, { ...meta, ip, userAgent });
    });
  },
});
```

The final step was to create the client side `logger` object which called the Meteor method with the info and wrapped the logger object so it works exactly like the winston `logger` object we created for the server.

I also do some filtering of log events below, only sending them to the server if they are high enough priority.

`/client/logger.js`
```js
import { addLogEntry } from '/imports/api/logs/methods';

const sendLogToServer = (level, message, meta) => {
  addLogEntry.call({
    level,
    message,
    meta,
  }, (err) => {
    if (err) {
      console.log(err);
    }
  });
};

// We are declaring 'logger' as a global variable to the entire server application
logger = {
  silly: () => { },
  debug: () => { },
  verbose: () => { },
  info: (message, meta) => sendLogToServer({ level: 'info', message, meta }),
  warn: (message, meta) => sendLogToServer({ level: 'warn', message, meta }),
  error: (message, meta) => sendLogToServer({ level: 'error', message, meta }),
};
```

With this small amount of code, I ended up with the isomorphic, multi-transport logging system that gave me easy flexibility to create detailed logs stored in a MongoDB collection as well as immediately notify me via Slack of any error conditions.

Another huge benefit of using a Slack channel for alerts? I can also set up other website services to hook in alerts to that channel (email bounces, hosting status updates, database monitoring alerts, ...). And not to mention it's free if you're okay with only keeping the last 10k messages.
