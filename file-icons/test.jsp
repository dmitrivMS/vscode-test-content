<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Order Summary</title>
</head>
<body>
    <h1>Order #${order.id}</h1>
    <p>Customer: <c:out value="${order.customerName}" /></p>
    <table>
        <tr><th>Item</th><th>Qty</th><th>Price</th></tr>
        <c:forEach var="item" items="${order.items}">
            <tr>
                <td>${item.name}</td>
                <td>${item.quantity}</td>
                <td><fmt:formatNumber value="${item.price}" type="currency" /></td>
            </tr>
        </c:forEach>
    </table>
    <p>Total: <fmt:formatNumber value="${order.total}" type="currency" /></p>
</body>
</html>
