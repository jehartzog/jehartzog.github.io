---
title: "To Git or not to Git - TutoringZone Source"
layout: post
date: 2015-04-20 17:00
tag:
- Git
- Moodle
- Website
image: /images/git-logo.jpg
category: blog
description: "Source Code Mangagement is a must-have for any project"
---
## Old Style Development

Anyone who has been developing long enough remembers the 'commando' style work-flows that used to be all to common: FTP in to a remote web server, edit files with notepad, save and refresh the page to see the changes. Perhaps you had two remote servers, one for development and one for production, but transferring work from one to another was always a hit-or-miss process and left you with a confounding array of backup directories with labels like 'May-3 update-index-layout-second-try'.

## What has Changed

Although everyone still acts surprised when they hear of a team of people still doing things the old style and not using any Source Code Management (SCM), we all know it's more prevalent than you might expect. As simple as it is to transition a project to SCM, it takes more effort to transition the people supporting that project.

## SCM and TutoringZone

When I took over management of TutoringZone.com in early 2015, I was provided a URL, SSH key and a 2 page word document from the previous developer. After I started digging around, I realized the only backups were a few manual EC2 snapshots and there was no version control for the source.

After realizing the risks involved with the current status of the site, my first major project was to implement SCM for the code base. While I had used Git in the past, this was a bigger undertaking of properly applying Git to a custom-built PHP application and ensuring proper synchronization between the production and development environment.

## End State

Although initially unsure about the change, the website owners were ecstatic once the integration was complete. They could get slack updates of commits with links to the corrected issues, with all the work being organized and searchable. Pushing updates to production went from being a careful dance of FTP file transfers to a single Git command to update the production server. If a code change broke something (which never happened on my watch), a rollback could be performed with a single Git command run from an iPhone.

The takeaway from this experience is that SCM integration is no longer an 'extra' feature, but rather one of the highest importance. If you find yourself joining a development team that has not yet seen the light, you need to take the effort to open their eyes and they will thank you for it at the end.
