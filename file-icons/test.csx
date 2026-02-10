#r "nuget: Newtonsoft.Json, 13.0.3"

using System;
using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json;

var employees = new List<(string Name, int Age, string Department)>
{
	("Alice", 30, "Engineering"),
	("Bob", 25, "Marketing"),
	("Carol", 35, "Engineering"),
	("David", 28, "Sales")
};

var engineeringTeam = employees
	.Where(e => e.Department == "Engineering")
	.OrderBy(e => e.Name)
	.ToList();

Console.WriteLine($"Engineering team has {engineeringTeam.Count} members:");
foreach (var (name, age, dept) in engineeringTeam)
{
	Console.WriteLine($"  {name} (age {age})");
}

var json = JsonConvert.SerializeObject(engineeringTeam, Formatting.Indented);
Console.WriteLine(json);
