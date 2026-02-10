Imports System
Imports System.Collections.Generic

Module InventoryModule
    Public Class Product
        Public Property Id As Integer
        Public Property Name As String
        Public Property Price As Decimal
        Public Property Quantity As Integer

        Public ReadOnly Property TotalValue As Decimal
            Get
                Return Price * Quantity
            End Get
        End Property

        Public Overrides Function ToString() As String
            Return $"{Name} (x{Quantity}) - ${TotalValue:F2}"
        End Function
    End Class

    Sub Main()
        Dim inventory As New List(Of Product) From {
            New Product With {.Id = 1, .Name = "Keyboard", .Price = 49.99D, .Quantity = 25},
            New Product With {.Id = 2, .Name = "Mouse", .Price = 29.99D, .Quantity = 40},
            New Product With {.Id = 3, .Name = "Monitor", .Price = 299.99D, .Quantity = 10}
        }

        For Each item In inventory
            Console.WriteLine(item.ToString())
        Next
    End Sub
End Module
