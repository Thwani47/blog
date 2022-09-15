+++
title = "Using Vite for React Applications"
tags = [
    "vite",
    "react",
    "web",
    "development",
]
date = "2022-09-15"
toc = true
+++

For a while, I have been using [Create React App (CRA)](https://reactjs.org/docs/create-a-new-react-app.html#create-react-app) to create React applications, which is an offically supported way to create single-page React applications. 

CRA was created for React beginners who have limited understanding of Webpack and it was not meant to be used in production. CRA also makes it very difficult to add custom build configurations. It also comes with many unrequried dependencies, resulting in a very bloated *package.json* when the app is ejected. Out of all these drawbacks, one that is very annoying is that CRA takes longer to build when our codebase increases, and even longer to deploy our applications. One alternative is to setup a React project without using CRA, another option is to use a development tool such as **Vite**.

You can find the source code for the examples in this article [here](https://github.com/Thwani47/blog-code/tree/main/vite-react-example)
## Table of Contents
1. [What is vite](#what-is-vite)
2. [Creating a React App With Vite](#creating-a-react-app-with-vite)

## What is Vite?
**[Vite](https://vitejs.dev/)** (pronounced "*veet*") is a development tool for scaffoling and bundling web projects. Vite has grown popuplar due to its blazing fast compilation and hot module replacement. To understand what makes Vite fast, you can read more on [this](https://vitejs.dev/guide/why.html) page.

Vite supports a list of templates, and as of writing these templates include:
- vanilla / vanilla-ts
- vue / vue-ts
- react / react-ts
- preact / preact-ts
- lit / lit-ts
- svelte / svelte-ts

## Creating a React App With Vite
To create a new Vite project, you run the command
```bash
$ npm create vite@latest
```
Enter the project name and follow the prompts to select React (JavaScript) as shown below ![Create Vite React Project](/posts/create-vite-react-project.PNG)
You can also scaffold the project using this one-liner:
```bash
$ npm init vite@latest vite-react-example --template react
```

After the project is scaffolded, cd into it, install the dependencies and start the dev server as follows:
```bash
$ cd vite-react-example
$ npm install
$ npm run dev
```
The default server port is **5173**. Visit [http://127.0.0.1:5173/](http://127.0.0.1:5173/). You should see something like:
![Vite React Start](/posts/vite-react-home-page.png)