<%-- 
    Document   : printorder
    Created on : 2019-jun-13, 20:02:07
    Author     : ulf
--%>
<%@page import="se.saljex.wms.Const"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ordernr=null;
    ordernr= request.getParameter("ordernr");
    %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%= Const.getBarcodeFontLinkHTML() %>
        <title>Skriv Order</title>
        <link rel="stylesheet" type="text/css" href="a.css">           
        <script>
            function p() {
                window.print();
                window.close();
            }
        </script>
    </head>
    <body onload="p()">
        <% request.setAttribute("ordernr", ordernr); %>
            <jsp:include page="/WEB-INF/getorder.jsp" flush="true" />
    </body>
</html>
