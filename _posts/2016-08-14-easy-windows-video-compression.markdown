---
title: "Reducing iPhone Video Bloat with Handbrake on Windows"
layout: post
date: 2016-08-14 17:00
tag:
- Script
- iOS
category: blog
image: /images/video-icon.png
description: "Save your hard drive by shrinking those oversize iPhone videos on Windows"
---
### Quick and Easy Picture Import Process
With the higher quality of mobile pictures these days, I find myself rarely bringing my bulky DSLR camera and relying on the always-present iPhone to capture pictures and video. It's always satisfying to sit back after a day of collecting pictures to scrub out poor pictures and organize them for later viewing, but the process is not always streamlined when it comes to video. 

I don't feel the need to pay Apple hundreds of dollars to add a little more memory to my iPhone, so I use [Dropbox camera uploads](https://www.dropbox.com/en/help/289) to automatically upload all my pictures when I'm on WiFi so I can delete them off my phone's local storage. This also makes it easy to jump on my desktop/laptop at any time and work on deleting the blurry and duplicate pictures.

### Uncompressed iPhone Videos are HUGE
While I was satisfied with the process for syncing and storing pictures, video was another battle. A 2 minute iPhone video would easily stack up at around 200MB, with any lengthy videos quickly exceeding a GB. While I could fire up [HandBrake](https://handbrake.fr/) and manually go through their GUI to compress every video, that is not really ideal for quickly scrubbing a folder before copying it all over to a permanent location. I wanted to be able to delete all the bad pictures and video, copy over the whole folder to a permanent location and be done with it.

For a long time I was too lazy to do anything about it, until I realized that iPhone video was taking up 40GB, roughly 30% of all my Dropbox files, unnecessarily filling up my expensive SSD's on every computer my wife and I shared. It was time to sit down and fix this.

### Help me Google!
A quick google search turned out a bunch of partial solutions which didn't exactly do what I wasn't looking for, or just didn't work at all, so I put together a quick windows script which would work. I'm sure this would be easier on macOS, but my MacBook Pro died and I'm holding off purchasing a new one while Apple takes [4 years to update their MacBook Pro line](http://www.bloomberg.com/news/articles/2016-08-10/apple-said-to-plan-first-pro-laptop-overhaul-in-four-years).

## Using HandBrake to Batch Convert Videos in a Folder Recursively with Windows Script

1. Download [HandBrake](https://handbrake.fr/) and install in default location.

2. In Windows Explorer, hold shift and right click the folder you want to process.

3. Copy and paste this command and hit enter:

```
for /R %f in ("*.mov") do ("C:\Program Files\Handbrake\HandBrakeCLI" -i "%f" -o "%f".mp4 —-preset="Normal" --x264-preset placebo -q 10
```

### Notes:
1. This will NOT delete your old files, as you will probably want to check to make sure the conversion work before doing that. It will make a compressed copy of the video right next to the current one with the added extension of '.mp4'. You can easily delete the larger copy later by searching for `*.mov` in the folder using Windows Explorer and deleting everything that comes up.

2. The last parameter `-q 10` stands for the 'constant quality' factor. You can pick a lower number to increase quality at the cost of a larger file, or raise the number to make the files smaller. I picked 10 after trying out different values on a test video until the compression wasn't very noticeable. The default value was 20, but there were way too many compression artifacts for me to overwrite all my precious puppy videos with smaller but blurrier versions!

3. The `--x264-preset placebo` tells HandBrake to go ahead and take the longest time needed to convert the files. Since I am compressing them once before storing permanent copies, I don't care about how long it takes, I just want the best compression and quality.

4. The conversion process will take iPhone video files that were saved portrait style and convert them to landscape, making them appear sideways. I didn't care much about fixing this in the script since you could just adjust that during playback, but if you know an easy way please let me know!

### Final Thoughts

I'm sure I'm not the only person who Googled how to do this on Windows and found nothing helpful, so hopefully this post helps somebody out in the future. Thanks to Google for ensuring magic like this can happen!
