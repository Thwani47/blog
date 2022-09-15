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

For a while, I have been using [Create React App (CRA)](https://reactjs.org/docs/create-a-new-react-app.html#create-react-app) to create React applications, which is an officially supported way to create single-page React applications. 

CRA was created for React beginners who have a limited understanding of Webpack and it was not meant to be used in production. CRA also makes it very difficult to add custom build configurations. It also comes with many unnecessary dependencies, resulting in a bloated *package.json* when the app is ejected. Out of all these drawbacks, one that is very annoying is that CRA takes longer to build when your codebase increases and even longer to deploy our applications. One alternative is to set up a React project without using CRA. Another option is to use a development tool such as **Vite**.

You can find the source code for the examples in this article [here](https://github.com/Thwani47/blog-code/tree/main/vite-react-example)
## Table of Contents
1. [What is vite](#what-is-vite)
2. [Creating a React App With Vite](#creating-a-react-app-with-vite)
3. [Pros and Cons of Vite](#pros-and-cons-of-vite)
4. [Summary](#summary)

## What is Vite?
**[Vite](https://vitejs.dev/)** (pronounced "*veet*") is a development tool for scaffolding and bundling web projects. Vite has grown popular due to its blazing fast compilation and hot module replacement. To understand what makes Vite fast, you can read more on [this page](https://vitejs.dev/guide/why.html).

Vite supports a list of template presets, and as of writing, these template presets include:
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
Enter the project name and follow the prompts to select React (JavaScript), as shown below. ![Create Vite React Project](/posts/create-vite-react-project.PNG)
You can also scaffold the project using this one-liner:
```bash
$ npm init vite@latest vite-react-example --template react
```

After the project is scaffolded, cd into it, install the dependencies, and start the dev server as follows:
```bash
$ cd vite-react-example
$ npm install
$ npm run dev
```
The default server port is **5173**. Visit [http://127.0.0.1:5173/](http://127.0.0.1:5173/). You should see something like:
![Vite React Start](/posts/vite-react-home-page.png)

## Setting Environment Variables
Vite exposes environment variables on the **import.meta.env** object. Some built-in variables include:
- `import.meta.env.MODE` &rarr; The mode the app is running in
- `import.meta.env.BASE_URL` &rarr; The base URL from which the app is served
- `import.meta.env.PROD` &rarr; A boolean value indicating whether the app is running in production
- `import.meta.env.DEV` &rarr; A boolean value indicating whether the app is running in development mode (An opposite of `import.meta.env.PROD`)
- `import.meta.env.SSR` &rarr; A boolean value indicating whether the app is running on the server

Vite uses `dotenv` to load any additional environment variables from the following files
```
.env
.env.local
.env.[mode]
.env.[mode].local
```
Any environment variable loaded via dotenv is exposed to the `import.meta.env` object as strings. To prevent any environment variables from leaking to the client accidentally, Vite will only expose variables prefixed with the `VITE_` prefix. For example, for the following environment variables, 
```
VITE_APP_USER=Thanos
APP_PASSWORD=gamora
```
only `VITE_APP_USER` will be exposed as `import.meta.env.VITE_APP_USER` to the client source code, `APP_PASSWORD` will not be exposed
```javascript
console.log(import.meta.env.VITE_APP_USER); // Thanos
console.log(import.meta.env.APP_PASSWORD); // undefined
```

## Pros and Cons of Vite
| Pros | Cons |
| - | - |
| Blazingly fast | Lack of first-class support for Jest |
| Ease of use | Different tooling for dev and production environments |
|Out of-the-box Typescript support | |
| Vite is framework agnostic | | 

## Summary
Vite is a good tool to scaffold web applications very fast and it helps save a lot more time than CRA. It is great too to create small projects and demos but it is recommended to not build any large-scale projects that will go into production using Vite as yet.