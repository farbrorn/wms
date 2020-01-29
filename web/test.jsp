<%-- 
    Document   : test
    Created on : 2019-jun-04, 22:29:32
    Author     : ulf
--%>
<%@page import="java.sql.ResultSetMetaData"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Connection"%>
<%@page import="se.saljex.wms.Const"%>

<%
    String s = request.getParameter("s");
    Connection ppgcon=Const.getPPGConnection(request);
    %>
    
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>

    </head>
    <body>
        <h1>Hello World!</h1>
        <form>
        <textarea name="s"><%= s %></textarea>
        <button type="submit">OK</button>
        </form>  
        <div>
            <%
                ResultSet rs = ppgcon.createStatement().executeQuery("select " + s);
ResultSetMetaData rsmd = rs.getMetaData();
int columnsNumber = rsmd.getColumnCount();
while (rs.next()) {
    for (int i = 1; i <= columnsNumber; i++) {
        if (i > 1) out.print(",  ");
        String columnValue = rs.getString(i);
        out.print(columnValue + " " + rsmd.getColumnName(i));
    }
    out.print("<br>");
}


                %>
                
       </div>
    </body>
</html>
