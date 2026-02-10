open System

type Shape =
    | Circle of radius: float
    | Rectangle of width: float * height: float
    | Triangle of base': float * height: float

let area = function
    | Circle r -> Math.PI * r * r
    | Rectangle (w, h) -> w * h
    | Triangle (b, h) -> 0.5 * b * h

let describe shape =
    let a = area shape
    match shape with
    | Circle r -> printfn "Circle (r=%.2f): area = %.2f" r a
    | Rectangle (w, h) -> printfn "Rectangle (%.2f x %.2f): area = %.2f" w h a
    | Triangle (b, h) -> printfn "Triangle (b=%.2f, h=%.2f): area = %.2f" b h a

let shapes = [
    Circle 5.0
    Rectangle (4.0, 7.0)
    Triangle (6.0, 3.0)
]

shapes |> List.iter describe
let totalArea = shapes |> List.sumBy area
printfn "Total area: %.2f" totalArea
