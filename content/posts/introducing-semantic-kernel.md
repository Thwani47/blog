+++
title = "A Beginner's Guide to  Semantic Kernel"
tags = [
    "ai-ml",
    "semantic-kernel"
]
date = "2023-08-27"
toc = true
+++

[Semantic Kernel](https://github.com/microsoft/semantic-kernel) is an open-source SDK that allows us to easily bring AI capabilities to our applications. It allows us to connect to AI services such as OpenAI and Azure OpenAI with ease. If you have worked with [LangChain](https://www.langchain.com/), Semantic Kernel is a Microsoft implementation of a project like LangChain. Semantic Kernel allows us to integrate AI functionality such as text generation, text summarization, chat completion, and image generation in our applications.

![sk-architecture](/images/sk_architecture.png)


In this article we will be introducing Semantic Kernel, covering some of the terminology used, and creating a basic C# application that uses Semantic Kernel.

The source code for the completed application can be found [here](https://github.com/Thwani47/blog-code/tree/main/SemanticKernelExample).

# Table of Contents
- [What is Semantic Kernel](#what-is-semantic-kernel)
- [Glossary of Terms](#glossary-of-terms)
- [Getting Started with Semantic Kernel in C#](#getting-started-with-semantic-kernel-in-c)

## What is Semantic Kernel
Semantic Kernel is a lightweight open-source SDK that allows developers to build their own copilot experiences. It allows us to easily integrate with AI plugins from Open AI and Microsoft. This means we can integrate our applications with plugins that are built for services such as ChatGPT, Bing, and Microsoft 365 Copilot. Semantic Kernel allows us to integrate with these plugins using programming languages such as Python, C#, and Java (support for TypeScript is not yet available at the time of writing but it is something that is being worked on). This means that we can leverage the power of LLMs in our applications by using the technology we use in our day-to-day development tasks.

Semantic Kernel provides an abstraction over integrating the power of LLMs in our applications. This makes the learning curve of learning and understanding the APIs for AI services such as Azure OpenAI and OpenAI shorter, and since we can use programming languages such as C# and Python, this means we can easily get started and we can easily integrate AI functionality in our applications. 

Before we can get started with Semantic Kernel, we need to understand a few terms that will make working with the SDK easier.

## Glossary of Terms
Here are some of the terms that are used widely in the world of Semantic Kernel. Understanding them will make your experience with the SDK an easier one.
| Term | Description |
| - | - |
| Ask | This refers to the goal sent to Semantic Kernel that a user or a developer would like to accomplish. |
| Kernel | The kernel refers to an instance of the processing engine that fulfills a user's ask using a collection of plugins. |
| Plugin | A plugin refers to a group of functions that can be exposed to AI services. For example, if we had a plugin for sprint planning, we might have a function to summarize the sprint planning meeting, a function to get the planned objectives for the sprint and a function to create work items for those objectives. <br><br>Semantic Kernel comes with some plugins out-of-the-box such as the TextMemory, ConversationSummary, FileIO, and Time plugins. You can also build custom plugins that suit your requirements. <br><br>Some Microsoft documentation might still use the term **"Skills"** for plugins. Plugins were initially called skills but were renamed to Plugins to conform to the OpenAI standard.|
| Functions &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| To create your custom plugin, Semantic Kernel allows you two create two types of functions:<br><br>**Semantic Functions**  &rarr; These functions allow your app to listen to users' asks and respond with a natural language response<br><br>**Native Functions** &rarr; These are functions that are written in Python or C# and the Kernel will call these functions based on users' asks|
| Planner | Semantic Kernel allows us to chain together different plugins that fulfill different goals. Semantic Kernel uses a function called a **Planner** that selects one or more functions from the registered plugins to execute based on the user's asks. For example, suppose we have a plugin named **WritePlugin** with the following functions defined:<br><br>**Brainstorm** &rarr; Given a goal or a topic, this function generates a list of ideas.<br>**ShortPoem** &rarr; Generates a short poem about a given topic.<br>**WriteStory** &rarr; Generates a short story with sub-chapters.<br>**Translate** &rarr; Translates a piece of text to your language of choice.<br><br>If the user's ask is **"Can you write a short poem in Spanish about living in Durban?"**, The Planner is responsible for selecting the functions to call and in the order they should be called. Which it will most likely (or should) call the **ShortPoem** and **Translate** functions|
| Prompts | Prompts serve as input to an AI model. Behind the scenes, Semantic Kernel Planner uses prompts to generate a plan (a list of actions to call and the order). <br><br>A model will generate different output based on the prompt provided.|
| Model | A model refers to a specific instance of an LLM* AI, such as GPT-3 or Codex.<br><br>**LLM (large language model) &rarr; An artificial intelligence model trained on a large text dataset.* | 

Let's get started with Semantic Kernel below

## Getting Started with Semantic Kernel in C#

To get started, you'll need an OpenAI API Key. You can obtain one by either creating an [OpenAI](https://openai.com/api/) account or creating an [Azure OpenAI Service](https://learn.microsoft.com/en-us/azure/cognitive-services/openai/quickstart?pivots=programming-language-studio). At the time of writing, access to the Azure OpenAI Service is only available by application. You can fill out your application [here](https://aka.ms/oai/access)

We'll build a C# console application that accepts a user's ask and can perform a set of actions. The application should be able to
- Summarize a piece of text
- Write a short poem about a topic
- Generate a short story about a topic
- Translate a piece of text to another language.

As much as we're using C#, the concepts should be the same in Python or Java if you prefer that. We will cover many of the concepts to get you started with Semantic Kernel, and in a follow-up article we'll learn how to give our applications 'memory';

We first start by creating a new .NET console application
```bash
$ dotnet new console --framework net7.0 --name SemanticKernelExample
$ cd SemanticKernelExample
```
We then have to install a few Nuget packages
```bash
$ dotnet add package Microsoft.SemanticKernel --prerelease
$ dotnet add package Microsoft.Extensions.Configuration.UserSecrets
```
*[Semantic Kernel](https://www.nuget.org/packages/Microsoft.SemanticKernel/) is still in preview at the time of writing this article, so we have to add the `--prerelease` flag to install the package.*

Define an app secret with your API Key using the command
```bash
$ dotnet user-secrets int
$ dotnet user-secrets set "OpenAI:APIKey" "<your-api-key>" #replace <your-api-key> with your Open API Key
```
We first need to create a kernel. We can create a kernel in two ways:

One, by calling the `KernelBuilder.Create()` method which returns an `IKernel` object
```csharp
var kernel = KernelBuilder.Create();
```
Two, by using the `KernelBuilder.Build()` method if we want to set extra configuration for the kernel such as loading the initial plugins, adding custom loggers, etc.
```csharp
var logger = NullLogger.Instance;
var kernel = new KernelBuilder().WithLogger(logger).Build();
```

For the **text summarization** functionality, we'll create a semantic function that will summarize an input text. We'll call this function **SummarizeText**. In your project root directory, create a **Plugins** folder, and inside that folder create a **WriterPlugin** folder. Inside the **WriterPlugin** folder, create a **SummarizeText** folder. Inside the **SummarizeText** folder create two files, **skprompt.txt** and **config.json**. The **skprompt.txt** file will contain the prompt that will be sent to the AI model, and the **config.json** file will contain the configuration for the function. The **skprompt.txt** file should contain the following text:
```txt
Summarize this in 3 sentences or less
{{$input}}
+++++
```
This is the prompt we'll pass to the AI service to summarize the text. During execution, Semantic Kernel will replace the `{{$input}}` value with the text to be summarized. 

Update the **config.json** file with the following
```json
{
  "schema": 1,
  "type": "completion",
  "completion": {
    "max_tokens": 500
  },
  "input": {
    "parameters": [
      {
        "name": "input",
        "description": "The text to summarize",
        "defaultValue": ""
      }
    ]
  }
}
```
This config instructs Semantic Kernel to restrict the generated text to 500 tokens and to expect an input parameter named **input**. The **defaultValue** property is used to set a default value for the parameter if one is not provided.

We can update our **Program.cs** file with the following to see the function in action
```csharp
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.SemanticKernel;

var configuration = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddUserSecrets<Program>()
    .Build();

var apiKey = configuration.GetSection("OpenAI:APIKey").Value; // Gets the OpenAI API Key from the app secrets

var logger = NullLogger.Instance;
var kernel = new KernelBuilder().WithLogger(logger).WithOpenAITextCompletionService("text-davinci-003", apiKey!)
    .Build(); // Creates a new kernel with the OpenAI Text Completion Service using the text-davinci-003 model

// You can see the list of models here: https://platform.openai.com/docs/models

var pluginsDirectory = Path.Combine(Directory.GetCurrentDirectory(), "Plugins");
var writerPlugin = kernel.ImportSemanticSkillFromDirectory(pluginsDirectory, "WriterPlugin"); // loads the WriterPlugin plugin

var textToSummarize =
    @"The Mars Perseverance Rover, a part of NASA's Mars Exploration Program successfully landed on Mars on February 18, 2021. 
Its mission is to explore the Martian surface, collect samples, and study the planet's geology and climate. 
The rover is equipped with advanced instruments and cameras that allow scientists to analyze the terrain and search for signs of past microbial life. 
This mission represents a significant step towards our understanding of Mars and its potential to support life in the past or present.";

var result = await writerPlugin["SummarizeText"].InvokeAsync(textToSummarize); // calls the SummarizeText function
Console.WriteLine(result);
```
This outputs something like the following
```text
The Mars Perseverance Rover successfully landed on Mars on February 18, 2021, as part of NASA's Mars Exploration Program. 
Its mission is to explore the Martian surface, collect samples, and study the planet's geology and climate. 
It is equipped with advanced instruments and cameras to analyze the terrain and search for signs of past microbial life.
```

In the completed solution, I've added the prompts and the config files for the other functions. You can find the completed solution [here](https://github.com/Thwani47/blog-code/tree/main/SemanticKernelExample). The updated **Program.cs** file should look like the following
```csharp
// ...kernel configuration

var pluginsDirectory = Path.Combine(Directory.GetCurrentDirectory(), "Plugins");
var writerPlugin = kernel.ImportSemanticSkillFromDirectory(pluginsDirectory, "WriterPlugin");

var textToSummarize =
    @"The Mars Perseverance Rover, a part of NASA's Mars Exploration Program successfully landed on Mars on February 18, 2021. 
Its mission is to explore the Martian surface, collect samples, and study the planet's geology and climate. 
The rover is equipped with advanced instruments and cameras that allow scientists to analyze the terrain and search for signs of past microbial life. 
This mission represents a significant step towards our understanding of Mars and its potential to support life in the past or present.";

var summary = await writerPlugin["SummarizeText"].InvokeAsync(textToSummarize);
Console.WriteLine($"Summarized text:\n{summary}");

var poem = await writerPlugin["WritePoem"].InvokeAsync("Being a Software Developer");
Console.WriteLine($"Generated poem:\n{poem}");

var shortStory = await writerPlugin["GenerateStory"].InvokeAsync("The Lion and the Lamb");
Console.WriteLine($"Generated story:\n{shortStory}");

var translationContext = kernel.CreateNewContext();
translationContext.Variables["input"] = textToSummarize;
translationContext.Variables["target"] = "French";

var translatedText = await writerPlugin["Translate"].InvokeAsync(translationContext);
Console.WriteLine($"Translated text:\n{translatedText}");
```
Notice we created a **translationContext** variable, which is a **SKContext** object. This object allows us, among other things, to be able to pass more than one value to our prompt. We use this since the **Translate** function needs the text to translate and the **target language**. Running this outputs something like the following
```text
*****Summarized text:*****

The Mars Perseverance Rover successfully landed on Mars on February 18, 2021, as part of NASA's Mars Exploration Program. Its mission is to explore the Martian surface, collect samples, and study the planet's geology and climate. It
is equipped with advanced instruments and cameras to analyze the terrain and search for signs of past microbial life.


*****Generated poem:*****

My coding skills are ever-growing,
My knowledge ever-expanding,
My work is never slowing,
My code is ever-commanding.

My projects are ever-thriving,
My skills are ever-thriving.

*****Generated story:*****

Once upon a time, there was a lion and a lamb who lived in the same forest. The lion was the king of the forest and the lamb was his loyal companion.

One day, the lion and the lamb went on a journey together. They encountered many obstacles along the way, but they worked together to overcome them.

Eventually, they reached their destination and the lion thanked the lamb for his help. From then on, the lion and the lamb were the best of friends and they lived happily ever after.


*****Translated text:*****

Le Rover Mars Perseverance, faisant partie du Programme d'Exploration de Mars de la NASA, s'est posé avec succès sur Mars le 18 février 2021.
Sa mission est d'explorer la surface martienne, de collecter des échantillons et d'étudier la géologie et le climat de la planète.
Le rover est équipé d'instruments et de caméras avancés qui permettent aux scientifiques d'analyser le terrain et de rechercher des signes de vie microbienne passée.
Cette mission représente une étape significative vers notre compréhension de Mars et de son potentiel pour soutenir la vie dans le passé ou le présent.
```

Lastly, we can use **Planner** to chain together different functions to fulfill a user's ask. We can update our **Program.cs** file with the following
```csharp
// ... Kernel config
var planner = new SequentialPlanner(kernel);
var ask = "Can you write a poem about being a software developer and translate it to German?";
var plan = await planner.CreatePlanAsync(ask);
var result = await plan.InvokeAsync();
Console.WriteLine(result);
```
This outputs something like the following
```text
Johns Leidenschaft für Programmierung war wie eine Flamme,
Seine Fähigkeiten und sein Wissen wuchsen stetig.
Er arbeitete hart, um die Welt zu einem besseren Ort zu machen,
Seine Arbeit war eine Quelle des Stolzes und der Anmut.
Er hörte nie auf zu lernen, immer bestrebt, zu wachsen,
Sein Einfluss auf die Welt wird er nie erfahren.
```

## Conclusion
In this article, we introduced Semantic Kernel, covered some of the terminology used, and created a basic C# application that uses Semantic Kernel. We've covered some of the basic terminology to help you get started with Semantic Kernel. In a follow-up article, we'll learn how to give our applications 'memory' using Semantic Kernel and have them remember context.

Semantic Kernel is still in its infancy stage but improvements are being made every day on the SDK and it will be a very powerful and mature tool in no time. We can use Semantic Kernel for a wide range of applications. We can leverage cutting-edge AI models and plugins in our apps, and we can also build our plugins. 