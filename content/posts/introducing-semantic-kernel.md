+++
title = "A Beginner's Guide to  Semantic Kernel"
tags = [
    "ai-ml",
    "semantic-kernel"
]
date = "2023-08-27"
toc = true
+++

[Semantic Kernel](https://github.com/microsoft/semantic-kernel) is an open-source SDK that allows us to easily bring AI capabilities to our applications. It allows us to connect to AI services such as OpenAI and Azure OpenAI with ease. If you have worked with [LangChain](https://www.langchain.com/), Semantic Kernel is a Microsoft implementation of a project like LangChain. Semantic Kernel allows us to integrate AI functionlity such as text generation, text summarization, chat completion, and image generation in our applications.

![sk-architecture](/images/sk_architecture.png)


In this article we will be introducing Semantic Kernel, covering some of the terminology used, creating a basic C# application that uses Semantic Kernel, and finally cover some use cases for Semantic Kernel

# Table of Contents
- [What is Semantic Kernel](#what-is-semantic-kernel)
- [Glossary of Terms](#glossary-of-terms)

## What is Semantic Kernel
Semantic Kernel is a light-weight open-source SDK that allows developers build thier own copilot experiences. It allows us to easily intergrate with AI plugins from Open AI and Microsoft. This means we can integrate our applications with plugins that  are build for services such as ChatGPT, Bing, and Microsoft 365 Copilot. Semantic Kernel allows us to integrate with these plugins using programming languages such as Python, C#, and Java (support for TypeScript is not yet available at the time of writing but it is something that is being worked on). This means that we can leverage the power of LLMs in our applications by using the technology we use in our day-to-day development tasks.

Semantic Kernel provides an abstraction over integrating the power of LLMs in our applications. This makes the learning curve of learning and understanding the APIs for AI services such as Azure OpenAI and OpenAI shorter, and since we can use programming languages such as C# and Python, this means we can easily get started and we can easily integrate AI functionality in our applications. 

Before we can get started with Semantic Kernel, we need to understand a few terms that will make working with the SDK easier.

## Glossary of Terms
Here are some of the terms that are used widely in the world of Semantic Kernel. Understanding them will make your experience with the SDK an easier one.
| Term | Description |
| - | - |
| Ask | This refers to the goal sent to Semantic Kernel that a user or a developer would like to accomplish. |
| Kernel | The kernel refers to instance of the processing engine that fulflls a user's ask using a collection of plugins. |
| Plugin | A plugin refers to a group of functions can be exposed to be AI services. For example, if we had a plugin for sprint planning, we might have a function to summarize the sprint planning meeting, a function to get the planned objectives for the sprint, and a function to create work items for those objectives. <br><br>Semantic Kernel comes with some plugins out-of-the-box such as the TextMemory, ConversationSummary, FileIO, and Time plugins. You can also build your own custom plugins that suit your requirements. |
| Functions &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| To create your own custom plugin, Semantic Kernel allows you two create two types of functions:<br><br>**Semantic Functions**  &rarr; These functions allow your app to listen to users' asks and respond with a natural language response<br><br>**Native Functions** &rarr; These are functions that are written in Python or C# and the Kernel will call these functions based on users' asks|
| Planner | Semantic Kernel allows us to chain together different plugins that fulfill different goals. Semantic Kernel uses a function called a **Planner** that selects one or more functions from the registered plugins to execute based on the user's asks. For example, suppose we have a plugin named **WritePlugin** with the following funtions defined:<br><br>**Brainstorm** &rarr; Given a goal or a topic, this function generates a list of ideas.<br>**ShortPoem** &rarr; Generates a short poem about a given topic.<br>**WriteStory** &rarr; Generates a short story with sub-chapters.<br>**Translate** &rarr; Translates a piece of text to your language of choice.<br><br>If the user's ask is **"Can you write a short poem in Spanish about living in Durban?"**, the Planner is responsible for selecting the functions to call and in the order they should be called. Which it will most likely (or should) call the **ShortPoem** and **Translate** functions|
| Prompts | Prompts serve as input to an AI model. Behind the scenes, Semantic Kernel Planner uses prompts to generate a plan (a list of actions to call and the order). <br><br>A model will generate different output based on the prompt provided.|
| Model | A model refers to a specific instance of an LLM* AI, such as GPT-3 or Codex.<br><br>**LLM (large language model) &rarr; An artificial intelligence model trained on a large text dataset.* | 
