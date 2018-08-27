---
title: "Code module sharing for React Native and Web"
layout: post
date: 2018-08-22 17:00
tag:
- React
- React Native
- Javascript
category: blog
description: "Quick and easy code sharing between React Native and React Web projects."
---

When reading about various options for native app development, a huge pitch for using React Native (RN) is that you don't need to switch context & languages, just use what you already know from web apps and it will mostly work!

While this is definitely true for almost all projects, if you're assembling a product with distinct but similar web and native releases, it's not just enough to be able work in the same general language, but you want to be able to share common code and functionality between your projects.

## The smaller code ecosystem of React Native

Without getting to deep into the weeds, React Native operates differently enough from the typical browser based DOM environment that only a fraction of third party code written from React web will operate seamlessly when pulled into a RN project. This is especially true for anything UI related, as anytime a project throws a `<div>` into its output, it's not longer good to go for RN.

After building a moderately complicated web app, I was used to pulling in well written UI libraries to handle a large amount of simple UI aspects, such as [react-bootstrap-table](http://allenfang.github.io/react-bootstrap-table/), [react-select](https://github.com/JedWatson/react-select), and [uniforms](https://github.com/vazco/uniforms). These libraries are not perfect, but tend to save you dev time while giving most of the features and UI that you need.

Later on when starting out with React Native, I was surprised to find the ecosystem a lot more limited than I initially expected. There was not a single go-to solution for styling/theming an app, with popular solutions like [NativeBase](https://nativebase.io/) being rather poorly documented and buggy implementation on basic features. I don't mean to bash their work, but it's a result of a working with a 'bleeding-edge' framework with a smaller dev pool to work with the projects.

## Sharing custom code

As a result of the lesser amount of high-quality libraries, we ended up using a larger amount of custom components than initially expected. The good thing about doing this is React components are actually pretty quick and stable to create, if you do it right, and you can expand them to fit exactly what you need.

After trying a number of methods and hitting build error after build error, the best solution ended up being relatively simple, if a bit clumsy. We maintain the actual code for all modules in a top level directory, and use a [build script](https://github.com/jehartzog/rn-web-shared-modules/blob/master/native-project/package.json#L15) to copy the entire module code directly into each project that uses them.

We use `rsync` during development, so it only updates files that are changed, and both CRNA and CRA build tools pick up on these changes and refresh the project right after you hit save. After we add those copied files to `.gitignore` and hide them from our code editor, the dev and build process is seamless, quick, and just works!

### Handling RN vs Web imports

A key feature in making this work is how the React Native build tools will always import the version of a file that has the extension `.native.js`, meaning your components could import a shared module, while still pulling in RN or web specific code when needed. You can see an example of this [here](https://github.com/jehartzog/rn-web-shared-modules/tree/master/modules/src/fancy-text/src).

## The 'cleaner' methods that didn't quite work

There are a number of far more 'correct' ways to do this that simply didn't pan out. Here are a few of them along with why they didn't work.

### Use local npm packages

This seemed by far the best way to manage [local packages](https://docs.npmjs.com/getting-started/installing-npm-packages-locally), but after npm v5 this is done via [symlinks](https://stackoverflow.com/questions/44624636/npm-5-install-folder-without-using-symlink). Unfortunately React Native build tools [do not support symlinks](https://github.com/facebook/metro/issues/1), and it has been this way for over a year.

This also means using `npm link` will not work out.

### Use remote npm packages

This can be done via private repository or using github to host the module. While this works better than local packages, they new issue that came up is the huge different in how the CRNA and CRA were set up to build. Basically React Native compiles everything with Babel, where Webpack in CRA excludes everything in node_modules. This will cause web build errors in all your modules, as Webpack will not be able to properly process anything ES6/JSX if Babel hasn't processed it yet.

For our Web app, we hadn't yet ejected CRA and I had no desire to do so just so I can spend a ton of time tweaking Webpack config to make this work. Other people have [had success](https://pickering.org/using-react-native-react-native-web-and-react-navigation-in-a-single-project-cfd4bcca16d0) doing it this way, but tweaking config and 'Monkey Patching' individual modules seemed more work than it was worht.

### Use `npm pack` + `npm install`

The answer to the above SO post, this solution did work but the actual pack operation takes 20+ seconds, even with a small number of package, which does not allow for acceptable iteration speed when trying to work on modules. It also still required additional dev/build scripts to keep the modules in sync.

## Try it out

If you want to see an example of this up and running, I've created a [github project](https://github.com/jehartzog/rn-web-shared-modules) which uses CRA and CRNA and sets up a few basic examples of using shared components between the two.
