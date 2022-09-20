+++
title = "Deep Dive Into .NET Minimal APIs"
tags = [
    "dotnet",
    "c#",
    "api"
]
date = "2022-09-20"
toc = true
+++

The release of .NET 6 introduced *minimal APIs*, which allows us to develop small and functional single-file web APIs. Minimal APIs were motivated by the amount of code required to produce a simple .NET API compared to producing an API providing similar functionality in other languages such as Python or Go. In this blog post, we will be taking a deep dive into minimal APIs, exploring how they differ from *controller-based* APIs, and seeing how to configure logging and dependency injection for a minimal API.

The complete source code for this article can be found [here](https://github.com/Thwani47/blog-code/tree/main/MinimalApiExample).

# Table of Contents
1. [Overview of .NET Minimal APIs](#overview-of-net-minimal-apis)
2. [Creating a Minimal API](#creating-a-minimal-api)
3. [Configuring a Minimal API](#configuring-a-minimal-api)
4. [CRUD methods in a Minimal API](#crud-methods-in-a-minimal-api)
5. [Summary](#summary)

## Overview of .NET Minimal APIs
Minimal APIs are designed to create web APIs with minimal dependencies. Minimal APIs are an ideal way for creating microservices and lightweight applications that include the minimum files, configuration, and dependencies required to build a functional API. Minimal APIs allow us to create an API with very few lines of code. We can get create an API with the following lines of code
```csharp
var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();
app.MapGet("/", () => "Hello World!");
app.Run();
```
Once we run the code above, we should see `Hello World!` in the browser. The minimal API code above is analogous to creating a hello world in [Express JS](http://expressjs.com/en/starter/hello-world.html).

Minimal APIs consist of:
- New hosting APIs
- WebApplication and WebApplicationBuilder
- New routing APIs

## Creating a minimal API
There are multiple ways to create a .NET minimal API. You can create a minimal API from Visual Studio (version > 2022) or the command line. We'll use the command line in this article. Run the following command to create a minimal API (You need to have the [.NET 6](https://dotnet.microsoft.com/en-us/download/dotnet/6.0) SDK installed for this command to work.)
```bash
$ dotnet new web --name MinimalApiExample --framework "net6.0"
```
This command creates a new .NET 6 web project, named `MinimalApiExample`, with the following files created in the project
- `appsettings.json`
- `appsettings.Development.json`
- `Program.cs`

Minimal APIs allow us to write our APIs in fewer files. We no longer have separate folders (and files) for controllers. We do not have the `Startup.cs` file anymore. We only have the `Program.cs` file for the API logic.

We can replace the lines
```csharp
var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();
```
with the line
```csharp
var app = WebApplication.Create(args);
```
if we want to create the application with preconfigured default values.

## Configuring a Minimal API
When a minimal API is created, the port the API application will respond to is specified inside the `Properties/launchSettings.json` file. We can specify the port(s) the app will respond to as follows:

We can set a single port: 
```csharp
// ... app configuration
app.MapGet("/", () => "Hello World!");
app.Run("http://localhost:3000");
```
Visiting [http://localhost:3000](http://localhost:3000) should print `Hello World!` on the browser.

We can set multiple ports as follows:
```csharp
// ... app configuration
app.Urls.Add("http://localhost:3000");
app.Urls.Add("http://localhost:4000");
app.MapGet("/", () => "Hello World!");
app.Run();
```
Visiting [http://localhost:3000](http://localhost:3000) or [http://localhost:4000](http://localhost:4000) should print `Hello World!` on the browser.

We can also specify the port when we run the app via the command line:
```bash
$ dotnet run --urls="http://localhost:3000"
# dotnet run --urls="http://localhost:3000;http://localhost:4000" for multiple ports
```
We can also specify the port from the environment variables as follows
```csharp
var app = WebApplication.Create(args);
var port = Environment.GetEnvironmentVariable("PORT") ?? "3000";
app.MapGet("/", () => "Hello World!");
app.Run($"http://localhost:{port}");
```

We can configure Swagger as follows. From the command line:
```bash
$ dotnet add package Swashbuckle.AspNetCore --version 6.2.3
```
In `Program.cs` add the following code
```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/swagger/v1/swagger.json", "v1");
        options.RoutePrefix = string.Empty;
    });
}

app.MapGet("/", () => "Hello World!");
app.Run();
```

## CRUD methods in a Minimal API
For example, we are going to create a simple *Todo* API, using an [EF Core In-Memory DB](https://learn.microsoft.com/en-us/ef/core/providers/in-memory/?tabs=dotnet-core-cli).

The API will have the following endpoints
| Endpoint | Description | Request Body | Response Body
| - | - | - | - |
| `GET /todos` | Get all Todos | None | List of Todos |
| `GET /todos/complete` | Get all complete Todos | None | Array of Todos | 
| `GET /todos/{id}` | Get a Todo item by its id | None | Todo item | 
| `POST /todos` | Create a new Todo item | Todo item | Todo item |
| `PUT /todos/{id}`| Update an existing Todo | Todo item | None |
| `DELETE /todos/{id}` | Delete a Todo item | None | None


To install the in-memory DB provider, run the following command in the command line
```bash
$ dotnet add package Microsoft.EntityFrameworkCore.InMemory
```
In the `Program.cs` file, add the following code to configure the `Todo` model and the DbContext
```csharp
// ... app configuration

app.Run();

public class Todo
{
    public Guid Id {get; set;}
    public string? Name {get; set;}
    public bool IsComplete {get; set;}
}

class TodoDb : DbContext
{
    public TodoDb(DbContextOptions<TodoDb> options) : base(options)
    {
    }

    public DbSet<Todo> Todos => Set<Todo>();
}
```
Add the following code to register the `DbContext` with the DI container
```csharp
//... builder configuration 

builder.Services.AddDbContext<TodoDb>(options => options.UseInMemoryDatabase("Todos"));

var app = builder.Build();

// ... rest of code
```

We add the following code to add endpoints for our API
```csharp
// .. app configuration

var app = builder.Build();

app.MapGet("/todos", async (TodoDb db) => await db.Todos.ToListAsync());
app.MapGet("todos/{id:guid}", async (Guid id, TodoDb db) =>
{
    var todo = await db.Todos.FindAsync(id); 
    return todo == null ? Results.NotFound() : Results.Ok(todo);
});
app.MapGet("/todos/complete", async (TodoDb db) => await db.Todos.Where(todo => todo.IsComplete).ToListAsync());
app.MapPost("todos", async (Todo todo, TodoDb db) =>
{
    db.Todos.Add(todo);
    await db.SaveChangesAsync();

    return Results.Created($"/todos/{todo.Id}", todo);
});

app.MapPut("todos/{id:guid}", async (Guid id, Todo update, TodoDb db) =>
{
    var todo = await db.Todos.FindAsync(id);

    if (todo == null)
    {
        return Results.NotFound();
    }

    todo.Title = update.Title;
    todo.IsComplete = update.IsComplete;

    await db.SaveChangesAsync();
    return Results.NoContent();
});

app.MapDelete("todos/{id:guid}", async (Guid id, TodoDb db) =>
{
    var todo = await db.Todos.FindAsync(id); 
    if (todo == null)
    {
        return Results.NotFound();
    }

    db.Todos.Remove(todo);
    await db.SaveChangesAsync();
    return Results.NoContent();
});

app.Run();

// ... rest of code

```

## Summary
Minimal APIs are an ideal way of building .NET APIs without much of the ceremony involved with controller-based APIs. They are good when we are writing applications in a microservices-based solution. They do not, however, replace controller-based APIs. As the complexity increases and we need more features in our APIs, controller-based APIs are more suitable to use. 