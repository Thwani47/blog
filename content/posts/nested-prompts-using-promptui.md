+++
title = "Nested Prompts in Go using promptui"
tags = [
    "go",
    "promptui",
    "cobra",
    "cli"
]
date = "2023-11-20"
toc = true
+++

I was working on a CLI tool written in Go, using the [Cobra](https://github.com/spf13/cobra) tool, and I had a use case where I needed a nested prompt for one of the commands. I was using [promptui](https://github.com/manifoldco/promptui) for the prompts and I couldn't find a straightforward way to do this. This short post will show how to create a nested prompt using `promptui`. The completed code can be found [here](https://github.com/Thwani47/nested-prompt).

We first need to create an empty Go project. We will call it `nested-prompt`:

```bash
$ mkdir nested-prompt && cd nested-prompt
$ go mod init github.com/Thwani47/nested-prompt 
```
We'll then install the `cobra`, `cobra-cli`, and `promptui` packages:

```bash
$ go get -u github.com/spf13/cobra@latest
$ go install github.com/spf13/cobra-cli@latest 
$ go get -u github.com/manifoldco/promptui
```

We can initialize a new CLI using the `cobra-cli` and a command to our CLI 
    
```bash
$ cobra-cli init            # initializes a new CLI application
$ cobra-cli add config      # adds a new command to the CLI named 'config'
```
We can clean up the `cmd/config.go` file and remove all the comments. It should be like this:

```go
// cmd/config.go
package cmd

import (
    "fmt"

    "github.com/spf13/cobra"
)

var configCmd = &cobra.Command{
    Use:   "config",
    Short: "Configure settings for the application",
    Long: `Configure settings for the application`,
    Run: func(cmd *cobra.Command, args []string) {
        fmt.Println("config called")
    },
}

func init() {
    rootCmd.AddCommand(configCmd)
}

```
We first need to create a custom type for our prompt. We do that by defining a `promptItem` struct as follows    
```go
type PromptType int

const (
    TextPrompt     PromptType = 0
    PasswordPrompt PromptType = 1
    SelectPrompt   PromptType = 2
)

type promptItem struct {
    ID            string
    Label         string
    Value         string
    SelectOptions []string
    promptType    PromptType
}
```
The `PromptType` enum allows us to collect different types of input from our prompts, we can prompt the user for text, or sensitive values such as passwords or API Keys, or prompt the user to select from a list of defined values

We then define a `promptInput` function that will prompt for input from the user. The function returns the string value entered by the user or an error if the prompt fails.
```go
func promptInput(item promptItem) (string, error) {
    prompt := promptui.Prompt{
        Label:       item.Label,
        HideEntered: true,
    }

    if item.promptType == PasswordPrompt {
        prompt.Mask = '*'
    }

    res, err := prompt.Run()

    if err != nil {
        fmt.Printf("Prompt failed %v\n", err)
        return "", err
    }

    return res, nil
}
```

We then define a `promptSelect` function that will allow the user to select from a list of options. The function returns the string value selected by the user or an error if the prompt fails.
```go
func promptSelect(item selectItem) (string, error) {
    prompt := promptui.Select{
        Label:        item.Label,
        Items:        item.SelectValues,
        HideSelected: true,
    }

    _, result, err := prompt.Run()

    if err != nil {
        fmt.Printf("Prompt failed %v\n", err)
        return "", err
    }

    return result, nil
}
```
To simulate a nested prompt, we will create a `promptNested` function that will allow us to prompt the user for a value and the prompt will stay active until the user selects `"Done"`. The function returns a boolean value that indicates that the prompt was a success. 

*The comments in the function explain what each major block of code is responsible for*
```go
func promptNested(promptLabel string, startingIndex int, items []*promptItem) bool {

    // Add a "Done" option to the prompt if it does not exist
    doneID := "Done"
    if len(items) > 0 && items[0].ID != doneID {
        items = append([]*promptItem{{ID: doneID, Label: "Done"}}, items...)
    }

    templates := &promptui.SelectTemplates{
        Label:    "{{ . }}?",
        Active:   "\U0001F336 {{ .Label | cyan }}",
        Inactive: "{{ .Label | cyan }}",
        Selected: "\U0001F336 {{ .Label | red  | cyan }}",
    }

    prompt := promptui.Select{
        Label:        promptLabel,
        Items:        items,
        Templates:    templates,
        Size:         3,
        HideSelected: true,
        CursorPos:    startingIndex, // Set the cursor to the last selected item
    }

    idx, _, err := prompt.Run()

    if err != nil {
        fmt.Printf("Error occurred when running prompt: %v\n", err)
        return false
    }

    selectedItem := items[idx]

    // if the user selects "Done", return true and exit from the function
    if selectedItem.ID == doneID {
        return true
    }

    var promptResponse string

    // if the prompt type is Text or Password, prompt the user for input
    if selectedItem.promptType == TextPrompt || selectedItem.promptType == PasswordPrompt {
        promptResponse, err = promptInput(*selectedItem)

        if err != nil {
            fmt.Printf("Error occurred when running prompt: %v\n", err)
            return false
        }

        items[idx].Value = promptResponse

    }

    // if the prompt type is Select, prompt the user to select from a list of options
    if selectedItem.promptType == SelectPrompt {
        promptResponse, err = promptSelect(*selectedItem)

        if err != nil {
            fmt.Printf("Error occurred when running prompt: %v\n", err)
            return false
        }
        items[idx].Value = promptResponse
    }

    if err != nil {
        fmt.Printf("Error occurred when running prompt: %v\n", err)
        return false
    }

    // recursively call the promptNested function to allow the user to select another option
    return promptNested(idx, items)
}
```

Now we have all the methods we need and we need to test them out. Inside the `Run` function of the `configCmd` command, we will create a list of `promptItem` and call the `promptNested` function to prompt the user for input. The `Run` function should look like this:

```go
// create a list of prompt items
items := []*promptItem{
    {
        ID:         "APIKey",
        Label:      "API Key",
        promptType: PasswordPrompt,
    },
    {
        ID:            "Theme",
        Label:         "Theme",
        promptType:    SelectPrompt,
        SelectOptions: []string{"Dark", "Light"},
    },
    {
        ID:            "Language",
        Label:         "Preferred Language",
        promptType:    SelectPrompt,
        SelectOptions: []string{"English", "Spanish", "French", "German", "Chinese", "Japanese"},
    },
}

// set the starting index to 0 to start at the first item in the list
promptNested("Configuration Items", 0, items)

for _, v := range items {
    fmt.Printf("Saving configuration (%s) with value (%s)...\n", v.ID, v.Value)
}
```

Build and test the application as follows
```bash
$ go build . 
$ ./nested-prompt config
```
The result is as follows
![nested-prompt](/images/nested-prompt.gif)