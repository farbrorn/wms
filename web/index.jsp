<%-- 
    Document   : index
    Created on : 2020-apr-19, 20:30:51
    Author     : ulf
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>WMS</title>
        <style>
            a, a:visited {
                color: blue;
            }
            .m {
                display: inline-block;
                margin: 8px;
                padding: 8px;
                background-color: lightblue;
                width: 360px;
                height: 80px;
                vertical-align: middle;
            }
            .m h4 {
                font-size: inherit;
                font-weight: bold;
                margin: 0px;
                font-size: 24px;
            }
        </style>
    </head>
    <body>
        <a href="order"><div class="m"><h4>Hantera Order</h4></div></a>
        <a href="order/redigeraorder.jsp"><div class="m"><h4>Redigera Order</h4></div></a>
        <a href="inlev"><div class="m"><h4>Hantera Inleveranser</h4></div></a>
        
    </body>
</html>
