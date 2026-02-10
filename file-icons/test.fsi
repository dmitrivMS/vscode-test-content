module App.Domain

open System

type Priority =
    | Low
    | Medium
    | High
    | Critical

type TodoItem = {
    Id: Guid
    Title: string
    Priority: Priority
    IsComplete: bool
    CreatedAt: DateTime
}

val createItem: title: string -> priority: Priority -> TodoItem
val complete: item: TodoItem -> TodoItem
val filterByPriority: priority: Priority -> items: TodoItem list -> TodoItem list
val summarize: items: TodoItem list -> unit
