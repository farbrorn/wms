<%-- 
    Document   : getorderrader
    Created on : 2019-jun-12, 19:14:49
    Author     : ulf
--%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="se.saljex.wms.Const"%>
<%@page import="java.sql.Connection"%>
<%
    Connection con=Const.getConnection(request);
    String ordernr=(String)request.getAttribute("ordernr");
    
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
if (ordernr!=null) {
    
    PreparedStatement ps;
   ps = con.prepareStatement("select o1.*, k.tel as k_tel, k.biltel as k_biltel from " + 
           Const.getOrder1Union("datum, kundnr, namn, adr1, adr2, adr3, annanlevadress, levadr1, levadr2, levadr3, referens, saljare, marke, fraktbolag, linjenr1, linjenr2, linjenr3, ordermeddelande") + " o1 left outer join kund k on k.nummer=o1.kundnr where o1.wmsordernr=?");
   ps.setString(1, ordernr);
   ResultSet o1=ps.executeQuery();
   
    ps = con.prepareStatement("select o2.*, l.ilager, l.lagerplats, a.refnr, a.plockinstruktion, s.finnsilager from " + 
    Const.getOrder2Union("pos, text, artnr, namn, best, enh, stjid") + " o2 join " + Const.getOrder1Union("lagernr") + " o1 on o1.wmsordernr=o2.wmsordernr "
            + " left outer join lager l on l.artnr=o2.artnr and l.lagernr=o1.lagernr left outer join artikel a on a.nummer=o2.artnr "
            + " left outer join stjarnrad s on s.stjid=o2.stjid and o2.stjid>0 "
            + " where o2.wmsordernr=? order by pos");
   ps.setString(1, ordernr);
   ResultSet o2=ps.executeQuery();
   int proc=0;
   if (o1.next()) {
%>
        <table>
        <% if (!Const.isEmpty(o1.getString("ordermeddelande"))) { %>
            <tr><td><%= Const.toHtml(o1.getString("ordermeddelande")) %></td></tr>
            
        <% } %>

        <% while (o2.next()) { %>
            <% if (!Const.isEmpty(o2.getString("text")) && Const.isEmpty(o2.getString("artnr"))) { %>
                <tr><td><%= Const.toHtml(o2.getString("text")) %></td></tr>
            <% } else { %>
                <tr><td>
                    <table>
                        <tr style="vertical-align: top;">
                            <td class="o22-artnr"><%= Const.toHtml(o2.getString("artnr")) %></td>
                            <td class="o22-namn"><%= Const.toHtml(o2.getString("namn")) %></td>
                            <td class="o22-enh"><%= Const.toHtml(o2.getString("enh")) %></td>
                            <%
                            Double best = o2.getDouble("best");
                            Double ilager = o2.getDouble("ilager");
                            if (best==null) best=0.0;
                            if (ilager==null) ilager=0.0;
                            if (Const.noNull(o2.getInt("finnsilager"))>0 ) ilager=best;
                            if (best.compareTo(0.0) <= 0) proc=0; 
                            else if(ilager.compareTo(best)>=0) proc=100;
                            else proc=(int)(ilager/best*100);

                            %>
                            <td><div style="width: 100px; height: 20px; text-align: center; overflow: visible; white-space: nowrap; border: 1px solid grey; position:relative;"><div style="top: 0; left:0; position: absolute; line-height: 20px; width: 100%; height: 100%; text-align: center; z-index: 10;"><%= Const.getFormatNumber(best,0) %>/<%= Const.getFormatNumber(ilager, 0) %></div><div style="background-color: lightgreen; position: absolute; top: 0; left: 0; height: 100%; width:<%= proc %>%"></div></div></td>
                        </tr>
                    </table>
                </td></tr>
            <% } %>
        <% } %>
        </table>
    <% } %>
<% } %>
