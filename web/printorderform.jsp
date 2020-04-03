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
        <title>Skriv Order Form</title>
        <link rel="stylesheet" type="text/css" href="a.css">           
        <%= Const.getBarcodeFontLinkHTML() %>
        <script>
            function startup() {
                var input=document.getElementById("ordernr");
                input.focus();
                input.select();

                input.addEventListener("keyup", function(event) {
                  // Number 13 is the "Enter" key on the keyboard
                  if (event.keyCode === 13) {
                    event.preventDefault();
                    document.getElementById("printbtn").click();
                  }
                });                
            }
            function p() {
                var inp=document.getElementById("ordernr");
                var o = inp.value;
                inp.focus();
                inp.select();
                window.open("printorder.jsp?ordernr=" + o, "_blank");
            }
        </script>
    </head>
    <body onload="startup()">
        Ordernr: <input type="text" id="ordernr" name="ordernr">
        <button id="printbtn" onclick="p()">Skriv ut</button>
    </body>
</html>
