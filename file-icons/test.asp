<%@ Language="VBScript" CodePage="65001" %>
<!DOCTYPE html>
<html>
<head>
    <title>Product Listing</title>
</head>
<body>
<%
Dim conn, rs, sql
Set conn = Server.CreateObject("ADODB.Connection")
conn.Open "Provider=SQLOLEDB;Data Source=localhost;Initial Catalog=Store;Integrated Security=SSPI;"

sql = "SELECT TOP 10 ProductName, Price, InStock FROM Products WHERE InStock = 1 ORDER BY ProductName"
Set rs = conn.Execute(sql)

Response.Write "<table border='1'>" & vbCrLf
Response.Write "<tr><th>Product</th><th>Price</th></tr>" & vbCrLf
Do While Not rs.EOF
    Response.Write "<tr><td>" & Server.HTMLEncode(rs("ProductName")) & "</td>"
    Response.Write "<td>$" & FormatNumber(rs("Price"), 2) & "</td></tr>" & vbCrLf
    rs.MoveNext
Loop
Response.Write "</table>"

rs.Close
conn.Close
Set rs = Nothing
Set conn = Nothing
%>
</body>
</html>
