<%@page import="se.saljex.wms.OrderGrupper.OrderGrupp"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="se.saljex.wms.Const"%>
<%@page import="java.sql.Connection"%>

<%
    String bildurl = Const.getBildUrl();
    String logourl="https://www.saljex.se/p/s200/logo-saljex";
    Integer lagernr=Const.getLagerNr();
    Connection con=Const.getConnection(request);
    ResultSet rs;
    PreparedStatement ps;
    String q;
    %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Boka utleverans</title>
        <%= Const.getBarcodeFontLinkHTML() %>
        <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/a.css">            
    </head>
    <body>
        
                
        
        <%
     q = "";
     
   ps=con.prepareStatement(q);  
   rs = ps.executeQuery();
   %>
   </body>
</html>
