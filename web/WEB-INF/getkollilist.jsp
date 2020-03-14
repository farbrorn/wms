<%-- 
    Document   : getkollilist
    Created on : 2020-mar-06, 11:13:00
    Author     : ulf
--%>

<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="se.saljex.wms.Const"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%            
    Connection con=Const.getConnection(request); 
    String wmsordernr = (String)request.getAttribute("wmsordernr");
    
    PreparedStatement ps = con.prepareStatement("select * from wmskollin where wmsordernr=? order by kolliid");
    ps.setString(1, wmsordernr);
    ResultSet rs = ps.executeQuery();
%>

<table>
    <tr class="tdrubrikrad"><td>Kollityp</td><td>Vikt (kg)</td><td>Längd (cm)</td><td>Bredd (cm)</td><td>Höjd (cm)</td><td></td></tr>
<% while(rs.next()) { %>
<tr>
    <td><%= Const.toHtml(rs.getString("kollityp")) %></td>
    <td><%= rs.getInt("viktkg") %></td>
    <td><%= rs.getInt("langdcm") %></td>
    <td><%= rs.getInt("breddcm") %></td>
    <td><%= rs.getInt("hojdcm") %></td>
    <td class="no-print"><a onclick="deleteKolli(<%= rs.getInt("kolliid") %>)" href="">Ta bort</a></td>
    
</tr>

<% } %>
</table>
