module App.Domain

open System

type Priority = Low | Medium | High | Critical

type TodoItem = {
    Id: Guid
    Title: string
    Priority: Priority
    IsComplete: bool
    CreatedAt: DateTime
}

let createItem title priority =
    { Id = Guid.NewGuid()
      Title = title
      Priority = priority
      IsComplete = false
      CreatedAt = DateTime.UtcNow }

let complete item = { item with IsComplete = true }

let filterByPriority priority items =
    items |> List.filter (fun i -> i.Priority = priority)

let summarize items =
    let total = List.length items
    let done = items |> List.filter (fun i -> i.IsComplete) |> List.length
    printfn "Tasks: %d total, %d complete, %d remaining" total done (total - done)
