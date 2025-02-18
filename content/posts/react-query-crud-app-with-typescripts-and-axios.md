+++
title = "Building a CRUD app with React Query, TypeScript, and Axios"
tags = [
    "typescript",
    "vite",
    "react-query"
]
date = "2023-03-20"
toc = true
+++

[TanStack Query](https://tanstack.com/query/latest), also known as **React Query** is described as the missing data-fetching library for web applications. **React Query** makes fetching, caching, synching, and updating server state a breeze.

React Query comes with an opinionated way of fetching and updating data. React Query makes it easier to manage complex data fetching and caching scenarios in our React applications while providing a simple and intuitive API as compared to traditional state management libraries. Using React Query also has other benefits such as:
- **Error handling** - React Query provides robust error handling capabilities. This helps with handling errors that occur during data fetching or mutations.
- **Global state management** - React Query provides a central place to manage global state. Making it easy to share data across components and avoid prop drilling
- **Type safety** - React Query is built with TypeScript and provides strong type safety. This makes it easier to catch errors and avoid bugs.
- **Optimistic updates** - React Query allows us to perform optimistic updates, which means we can update the UI immediately after a mutation is performed, before waiting for the server response.
- **Automatic data re-fetching** - React Query can automatically re-fetch data from the server based on several conditions, such as when a mutation is performed, the window is refocused, or a component is mounted.

In this article, we will be learning how to use React Query to fetch and update server data in a React application using Axios.

The complete source code for this article can be found [here](https://github.com/Thwani47/blog-code/tree/main/react-query-crud-example)

# Table of Contents
- [Table of Contents](#table-of-contents)
  - [Creating the project](#creating-the-project)
  - [Setting up the backend server](#setting-up-the-backend-server)
  - [Setting up React Query](#setting-up-react-query)
  - [Setting up Axios](#setting-up-axios)
  - [Fetch all Todos](#fetch-all-todos)
  - [Add a new Todo](#add-a-new-todo)
  - [Delete a Todo](#delete-a-todo)
  - [Edit a Todo](#edit-a-todo)
  - [Conclusion](#conclusion)



## Creating the project

We'll be using [Vite](https://thwanisithole.co.za/posts/using-vite-for-react-apps/) for our web app. Run
```bash
$ npm create vite@latest react-query-crud-example
```
and follow the prompts to select `React` as the framework and `TypeScript` as the variant. Change the directory into the project directory and run
```bash
$ npm i @tanstack/react-query @tanstack/react-query-devtools axios formik yup react-router-dom json-server
$ npm i -D tailwindcss postcss autoprefixer
```
The above commands install:
- React Query
- React Query dev tools
- Axios - an HTTP client.
- formik - a React Form Library.
- yup - A form data validation library.
- React Router - a React routing library.
- JSON Server - a fake REST API. We'll be using this as the backend server to fetch data from and send data to.
- Tailwind CSS - A CSS framework we'll use to style our components.

Run 
```bash
$ npx tailwindcss init -p
```
to generate a `tailwind.config.cjs` file. Replace the contents of  `tailwind.config.cjs` with
```js
/*tailwind.config.cjs*/

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

Replace the contents of **index.css** with 
```css
/*index.css*/
@tailwind base;
@tailwind components;
@tailwind utilities;
```

## Setting up the backend server
We'll be using [json-server](https://github.com/typicode/json-server) to create the REST API that we'll fetch data from. In the root of the project, create a **db.json** file with the contents
```js
/*db.json*/

    {
        "todos" : [
            {
                "id" : 1,
                "title": "Learn React Query",
                "complete": false
            }
        ]
    }
```
In the **package.json** file, add a **server** script as follows
```js
/*package..json*/

// ...
"scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "server" : "json-server --watch db.json --port 5000" // ADD THIS LINE
  }
// ...
```

In the command line, run 
```bash
$ npm run server
```
This exposes a REST API that we can consume from http://localhost:5000/todos. The API exposes these endpoints

| Endpoint | Action |
| - | - | - | - |
| `GET /todos` | Get all Todos | 
| `GET /todos?complete=true` | Get all complete Todos |
| `GET /todos/{id}` | Get a Todo item by its id |
| `POST /todos` | Create a new Todo item | 
| `PUT /todos/{id}`| Update an existing Todo |
| `DELETE /todos/{id}` | Delete a Todo item |

## Setting up React Query
To be able to use React Query in our application, we need to wrap the `QueryClientProvider` component around our application entry point. Update the `main.tsx` file as follows
```typescript
/*main.tsx*/
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './index.css';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import { createBrowserRouter, RouterProvider } from 'react-router-dom';

const queryClient = new QueryClient();

const router = createBrowserRouter([
    {
        path: '/',
        element: <App />
    },
    {
        path : '*',
        element : <h1>Page not found: 404</h1>
    }
]);

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
    <React.StrictMode>
        <QueryClientProvider client={queryClient}>
            <RouterProvider router={router}/>
            <ReactQueryDevtools />
        </QueryClientProvider>
    </React.StrictMode>
);
```
React Query works with zero config and can be customized to meet our application requirements. The above sets up React Query with the default options. We can configure our config options by passing a config object into the query client as follows
```js
... 
const queryClient = new QueryClient({
    queries : { // data fetching config
        refetchOnWindowFocus : false,
        refetchOnMount : false,
        retry: false,
        // ... rest of the config
    },
    mutations : { // mutations config

    }
});
// rest of code...
```

## Setting up Axios
Create a new `src/api/client.ts` file with the following contents
```js
import axios from "axios";

export const client = axios.create({
    baseURL : 'http://localhost:5000/todos',
    headers: {
        'Content-Type': 'application/json'
    }
})
```
This creates and exports an axios client with the base URL of our server setup.

## Fetch all Todos
In the main page of the app, we want to fetch all todo items from the server.

First, create a `src/types/todo.types.ts` file with the contents
```typescript
export interface TodoItem {
    id: number;
    title: string;
    complete: boolean;
}
```

Create a `src/hooks/useFetchTodos.ts` file with the contents
```js
/*useFetchTodos.ts*/

import { QueryObserverResult, useQuery } from '@tanstack/react-query';
import { AxiosResponse } from 'axios';
import { client } from '../api/client';
import { TodoItem } from '../types/todo.types';

const fetchTodos = async (): Promise<AxiosResponse<TodoItem[], any>> => {
    return await client.get<TodoItem[]>('/');
};

export const useFetchTodos = (): QueryObserverResult<TodoItem[], any> => {
    return useQuery<TodoItem[], any>({
        queryFn: async () => {
            const { data } = await fetchTodos();
            return data;
        },
        queryKey: [ 'todos' ]
    });
};
```
This creates a `useFetchTodos` hook that fetches data from the API server.

We can use our hook in our `App.tsx` as follows:
```typescript
/*App.tsx*/

import { useNavigate } from 'react-router-dom';
import './App.css';
import { useFetchTodos } from './hooks/useFetchTodos';

function App() {
  const { data: todos, isLoading, isError } = useFetchTodos();
  const navigate = useNavigate();
    return (
        <div className="w-full mt-2 items-center bg-gray-100 min-h-screen">
            <h1 className="text-4xl font-bold mb-4">Todo List</h1>
      <button className="bg-green-500 hover:bg-green-700 text-white font-bold py-1 px-2 ml-2 rounded mb-4" onClick={() => navigate('/add-todo')}>New Todo</button>
      <hr className="mb-2"/>
      {
        isLoading? <h1>Loading...</h1> : isError ? <h1>Error fetching todos</h1> : (
          <ul>
          {todos?.map(todo => {
            return <li className={`mb-2 text-xl ${todo.complete ? 'line-through' : ''}`} key={todo.id}>{todo.title}
              <button className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-1 px-2 ml-2 rounded">Edit</button>
              <button className="bg-red-500 hover:bg-red-700 text-white font-bold py-1 px-2 ml-2 rounded">Delete</button>
            </li>
          })}
          </ul>
        )
      }
        </div>
    );
}

export default App;

```

## Add a new Todo
First, we create a `TodoItemForm.tsx` component with the contents
```typescript
import React from 'react';
import { ErrorMessage, Field, Form, Formik } from 'formik';
import * as yup from 'yup';
import { TodoInput, TodoItem } from './types/todo.types';

type Props = {
    action: string;
    todoItem: TodoItem | undefined;
    handleSubmit: (values: TodoInput) => void;
};

export default function TodoItemForm({ todoItem, handleSubmit, action }: Props) {
    return (
        <Formik
            initialValues={{
                title: todoItem? todoItem.title : '',
                complete: todoItem ? todoItem.complete: false
            }}
            validationSchema={yup.object({
                title: yup.string().required('Title is required')
            })}
            onSubmit={(values: TodoInput) => handleSubmit(values)}
        >
            <Form>
                <div className="mb-2">
                    <label htmlFor="title" className="mr-2">
                        Title
                    </label>
                    <Field
                        name="title"
                        type="text"
                        id="title"
                        className="shadow appearance-none border rounded py-1 px-2 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
                    />
                    <ErrorMessage name="title" component="span" className="text-red-500" />
                </div>
                <div>
                    <label htmlFor="complete" className="mr-2">
                        Complete
                    </label>
                    <Field name="complete" type="checkbox" id="complete" />
                </div>
                <button className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-1 px-2 ml-2 rounded">
                    {action}
                </button>
            </Form>
        </Formik>
    );
}

```
We're creating a reusable component that will come in handy when we want to edit our Todos

Then we create an `src/AddTodo.tsx` component with the following contents
```typescript
import React from 'react';
import { useAddTodo } from './hooks/useAddTodo';
import TodoItemForm from './TodoItemForm';

export default function AddTodo() {
    const { mutate: addTodo } = useAddTodo();

    return (
        <div className="w-full mt-2 items-center bg-gray-100 min-h-screen">
            <h1 className="text-4xl font-bold mb-4">New Todo</h1>
            <TodoItemForm todoItem={undefined} handleSubmit={addTodo} action="Add Todo" />
        </div>
    );
}
```

We then add the component to our router in `main.tsx` as follows
```typescript
import AddTodo from './AddTodo';
// ...

const router = createBrowserRouter([
    {
        path: '/',
        element: <App />
    },
    {
        path: '/add-todo',
        element: <AddTodo/>
    },
    {
        path : '*',
        element : <h1>Page not found: 404</h1>
    }
]);

// ...
```
We then need to create a `src/hooks/useAddTodo.ts` hook, the one we reference in our `AddTodo` component. Create a `src/hooks/useAddTodo.ts` with the following contents

```js

import { UseBaseMutationResult } from '@tanstack/react-query';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { AxiosResponse } from 'axios';
import { useNavigate } from 'react-router-dom';
import { client } from '../api/client';
import { TodoInput } from '../types/todo.types';

const addTodo = async (todo: TodoInput): Promise<AxiosResponse<TodoInput, any>> => {
    return await client.post<TodoInput>('/', todo);
};

export const useAddTodo = (): UseBaseMutationResult<AxiosResponse<TodoInput, any>, unknown, TodoInput, unknown> => {
    const queryClient = useQueryClient();
    const navigate = useNavigate();
    return useMutation({
        mutationFn: (todo: TodoInput) => addTodo(todo),
        onSuccess: () => {
            queryClient.invalidateQueries([ 'todos' ]);
            navigate('/', { replace: true });
        }
    });
};
```
Add the following `TodoInput` definition to `src/types/todo.types.ts`
```typescript
export interface TodoInput {
    title: string;
    complete: boolean;
}
```

## Delete a Todo
To delete a todo we first add a `src/hooks/useDeleteTodo.ts` hook file with the contents
```js
import { UseBaseMutationResult } from '@tanstack/react-query';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { AxiosResponse } from 'axios';
import { client } from '../api/client';

const deleteTodo = async (todoId: number): Promise<AxiosResponse<any, any>> => {
    return await client.delete(`/${todoId}`);
};

export const useDeleteTodo = (): UseBaseMutationResult<AxiosResponse<any, any>, unknown, number, unknown> => {
    const queryClient = useQueryClient();
    return useMutation({
        mutationFn: (todoId: number) => deleteTodo(todoId),
        onSuccess: () => {
            queryClient.invalidateQueries([ 'todos' ]);
        }
    });
};
``` 
Then update `App.tsx` and add an `onClick` event handler to the delete button as follows
```typescript
// ...
import {useDeleteTodo} from './hooks/useDeleteTodo'

function App(){
    // ...
    const {mutate : deleteTodo} = useDeleteTodo()

    return (
        //...
        {todos?.map(todo => {
            return 
                <li className={`mb-2 text-xl ${todo.complete ? 'line-through' : ''}`} key={todo.id}>{todo.title}
                    <button className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-1 px-2 ml-2 rounded">Edit</button>
                    <button 
                        className="bg-red-500 hover:bg-red-700 text-white font-bold py-1 px-2 ml-2 rounded" 
                        onClick={() => deleteTodo(todo.id)}>
                        Delete
                    </button>
                </li>
            })}
    )
}
```
## Edit a Todo
We first create an `EditTodo.tsx` component with the contents
```typescript

import React from 'react';
import { useParams } from 'react-router-dom';

import { useFetchTodo } from './hooks/useFetchTodo';
import { useEditTodo } from './hooks/useEditTodo';
import TodoItemForm from './TodoItemForm';


export default function EditTodo() {
    const { id } = useParams();
    const { data: todoItem, isLoading } = useFetchTodo(id ? parseInt(id) : 0);

    const { mutate: editTodo } = useEditTodo(id ? parseInt(id) : 0);
    return (
        <div className="w-full mt-2 items-center bg-gray-100 min-h-screen">
            <h1 className="text-4xl font-bold mb-4">Edit Todo</h1>
            {isLoading? <h1>Fetching todo...</h1> : <TodoItemForm todoItem={todoItem} handleSubmit={editTodo} action="Edit Todo"/> }
        </div>
    );
}

```


We then add the component to our router in `main.tsx` as follows
```typescript
import EditTodo from './EditTodo';
// ...

const router = createBrowserRouter([
    {
        path: '/',
        element: <App />
    },
    {
        path: '/add-todo',
        element: <AddTodo/>
    },
    {
        path: '/edit-todo/:id',
        element: <EditTodo />
    },
    {
        path : '*',
        element : <h1>Page not found: 404</h1>
    }
]);

// ...
```

Then update `App.tsx` and add an `onClick` event handler to the edit button as follows
```typescript
{isLoading? <h1>Loading...</h1> : isError ? <h1>Error fetching todos</h1> : (
    <ul>
    {todos?.map(todo => {
        return <li className={`mb-2 text-xl ${todo.complete ? 'line-through' : ''}`} key={todo.id}>{todo.title}
        <button className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-1 px-2 ml-2 rounded" onClick={() => navigate(`/edit-todo/${todo.id}`)}>Edit</button>
        <button className="bg-red-500 hover:bg-red-700 text-white font-bold py-1 px-2 ml-2 rounded" onClick={() => deleteTodo(todo.id)}>Delete</button>
        </li>
    })}
    </ul>
)}
```

We then create two hooks, a `useFetchTodo` hook that allows us to fetch data for a single Todo item and a `useEditTodo` hook that allows us to edit a Todo item

Create a `src/hooks/useFetchTodo.ts` file with the following contents
```js
import { QueryObserverResult, useQuery } from '@tanstack/react-query';
import { AxiosResponse } from 'axios';
import { client } from '../api/client';
import { TodoItem } from '../types/todo.types';

const fetchTodo = async (todoId: number): Promise<AxiosResponse<TodoItem, any>> => {
    return await client.get<TodoItem>(`/${todoId}`);
};

export const useFetchTodo = (todoId: number): QueryObserverResult<TodoItem, any> => {
    return useQuery<TodoItem, any>({
        queryFn: async () => {
            const { data } = await fetchTodo(todoId);
            return data;
        },
        queryKey: [ 'todo', todoId ]
    });
};
```
Then add a  `src/hooks/useEditTodo.ts` file with the following contents
```js
import { UseBaseMutationResult } from '@tanstack/react-query';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { AxiosResponse } from 'axios';
import { useNavigate } from 'react-router-dom';
import { client } from '../api/client';
import { TodoInput } from '../types/todo.types';

const editTodo = async (todoId: number, todo: TodoInput): Promise<AxiosResponse<TodoInput, any>> => {
    return await client.put<TodoInput>(`/${todoId}`, todo);
};

export const useEditTodo = (
    todoId: number
): UseBaseMutationResult<AxiosResponse<TodoInput, any>, unknown, TodoInput, unknown> => {
    const queryClient = useQueryClient();
    const navigate = useNavigate();
    return useMutation({
        mutationFn: (todo: TodoInput) => editTodo(todoId, todo),
        onSuccess: () => {
            queryClient.invalidateQueries([ 'todos' ]);
            navigate('/', { replace: true });
        }
    });
};
```

## Conclusion
React Query is a powerful library that makes data fetching and state management in React applications easy and efficient. It provides a simple and intuitive API for managing server state and has features such as caching, re-fetching, polling, and more. 

In this article we saw how to create a new React application, set up React Query, and fetch data from a REST API using Axios. There is a lot of React Query that we haven't touched on in this article, such as configuration, testing, etc, as it is outside the scope of this article.
