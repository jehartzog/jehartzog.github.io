---
title: "Ansible and Vagrant for local Moodle development"
layout: post
date: 2016-04-23 17:00
tag:
- Ansible
- Vangrant
- VirtualBox
- PHP
- Moodle
- MySQL
- MariaDB
- Website
- LAMP
- Git
image: /images/ansible-logo.png
category: blog
description: "Exploring local Moodle development using Vagrant and Ansible."
---
# Dev server - Local or remote VM?

## Discussion

A common way for a project to get started is to fire up a cloud VM, often pre-configured for the application we want to create (MEAN, LAMP, Meteor, etc...) and start writing code. When it comes time to separate out a staging/production server, it's easy to copy this VM, change some configuration and call it good.

This approach, while straightforward to get started with, has limitations that help promote another approach: local development.

## Modern tooling enabling easy full-stack development on any OS

Whether you run Windows, OS X, or Linux, the tools available these days will allow you to easily spin up any type of server you want and have it configured, provisioned, and ready to serve your application. While there are a number solutions out there for this situation (bash script, Chef, Salt, Puppet), I'm going to focus on the tools I found to have the perfect balance between functionality and simplicity, Vangrant and Ansible.

You can see the end results of my work on [GitHub](https://github.com/jehartzog/ansible-moodle-dev).
