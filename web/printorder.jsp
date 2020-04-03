<%-- 
    Document   : printorder
    Created on : 2019-jun-13, 20:02:07
    Author     : ulf
--%>
<%@page import="se.saljex.wms.Const"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ordernr=null;
    ordernr= request.getParameter("wmsordernr");
    %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
        <meta http-equiv="Pragma" content="no-cache" />
        <meta http-equiv="Expires" content="0" />        <title>Redigera order</title>
        <%= Const.getBarcodeFontLinkHTML() %>
        <title>Skriv Order</title>
        <link rel="stylesheet" type="text/css" href="a.css">           
        <script>
            function p() {
            var is_chrome = Boolean(window.chrome);
            if (is_chrome) {
                    setTimeout(function () { // wait until all resources loaded 
                        window.print();  // change window to winPrint
                        window.close();// change window to winPrint
                    }, 200);
            }
            else {
                window.print();
                window.close();
            }      
        }
        </script>
    </head>
    <body onload="p()">
        <% request.setAttribute("ordernr", ordernr); %>
            <jsp:include page="/WEB-INF/getorder.jsp" flush="true" />
    </body>
</html>
