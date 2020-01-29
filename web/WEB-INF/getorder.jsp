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
    String ordernr= (String)request.getAttribute("ordernr");
    
    PreparedStatement ps;
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% if (ordernr!=null) { %>      

<%        
              
   ps = con.prepareStatement("select o1.*, k.tel as k_tel, k.biltel as k_biltel from " + 
           Const.getOrder1Union("datum, kundnr, namn, adr1, adr2, adr3, annanlevadress, levadr1, levadr2, levadr3, referens, saljare, marke, fraktbolag, linjenr1, linjenr2, linjenr3, ordermeddelande, levdat") + " o1 left outer join kund k on k.nummer=o1.kundnr where o1.wmsordernr=?");
   ps.setString(1, ordernr);
   ResultSet o1=ps.executeQuery();
   ps = con.prepareStatement("select o2.*, l.ilager, l.lagerplats, a.refnr, a.plockinstruktion, s.finnsilager from " + 
    Const.getOrder2Union("pos, text, artnr, namn, best, enh, stjid") + " o2 join " + Const.getOrder1Union("lagernr") + " o1 on o1.wmsordernr=o2.wmsordernr "
            + " left outer join lager l on l.artnr=o2.artnr and l.lagernr=o1.lagernr left outer join artikel a on a.nummer=o2.artnr "
            + " left outer join stjarnrad s on s.stjid=o2.stjid and o2.stjid>0 "
            + " where o2.wmsordernr=? order by pos",ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
   ps.setString(1, ordernr);
   ResultSet o2=ps.executeQuery();
   if (o1.next()) {
    String logourl=Const.getLogoUrl(con, o1.getString("dbschema"));
  %>      
    
<div class="order">
  <div class="orderhuvud">
      <table>
          <tr>
              <td class="o1-r1c1">
                  <img src="<%= logourl %>">
              </td>
              <td class="o1-r1c2">ORDER</td>
              <td class="o1-r1c3">
                  Ordernr: <%= o1.getString("wmsordernr") %><br>
                  Datum: <%= o1.getString("datum") %>
              </td>
          </tr>
      </table>
    <div class="streckkod">*<%= o1.getString("wmsordernr") %>*</div>
      <table>
          <tr>
              <td class="o1-r2c1">
                  <div class="o1-rubrik">Kund</div>
                  <div class="o1-adrruta">
                  <%= Const.toHtml(o1.getString("namn")) %><br>
                  <%= Const.toHtml(o1.getString("adr1")) %><br>
                  <%= Const.toHtml(o1.getString("adr2")) %><br>
                  <%= Const.toHtml(o1.getString("adr3")) %>
                  </div>
              </td>
              <td class="o1-r2c2">
                  <div class="o1-rubrik">Leveransadress</div>
                  <div class="o1-adrruta <%= o1.getInt("annanlevadress")>0 ? "bold-border" : "" %>">
                  <%= Const.toHtml(o1.getString("levadr1")) %><br>
                  <%= Const.toHtml(o1.getString("levadr2")) %><br>
                  <%= Const.toHtml(o1.getString("levadr3")) %>
                  </div>
            </td>
          </tr>
      </table>
        <table>
            <tr>
                <td class="o1-r3c1">
                    <div class="o1-rubrik">Vår ref:</div>
                    <div class="text"><%= Const.toHtml(o1.getString("saljare")) %></div>
                    <div class="o1-rubrik">Er ref:</div>
                    <div class="text"><%= Const.toHtml(o1.getString("referens")) %></div>
                    <div class="o1-rubrik">Tel:</div>
                    <div class="text"><%= Const.toHtml(o1.getString("k_tel")) %> <%= Const.toHtml(o1.getString("k_biltel")) %></div>
                </td>
                <td class="o1-r3c2">
                    <% if (o1.getString("levdat")!=null) { %>
                    <div class="border">
                        <div class="o1-rubrik">Leveransdatum</div>
                        <div class="text bold"><%= o1.getString("levdat") %></div>
                    </div>
                    <% } %>
                    <div class="o1-rubrik">Godsmärke</div>
                    <div class="text"><%= Const.toHtml(o1.getString("marke")) %></div>
                    <div class="o1-rubrik">Transportsätt:</div>
                    <div class="text">
                    <%= Const.toHtml(o1.getString("fraktbolag")) %>
                    <%= Const.toHtml(o1.getString("linjenr1")) %>
                    <%= Const.toHtml(o1.getString("linjenr2")) %>
                    <%= Const.toHtml(o1.getString("linjenr3")) %>
                    </div>
                </td>
            </tr>
        </table>
  </div>

  <div class="orderrader">
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
                        <td class="o2-bild" rowspan="2"><img onerror="this.style.display='none';" src="<%= Const.getBildUrl() %><%= o2.getString("artnr") %>"></td>
                        <td class="o2-lagerplats"><%= Const.toHtml(o2.getString("lagerplats")) %></td>
                        <td class="o2-artnr"><%= Const.toHtml(o2.getString("artnr")) %></td>
                        <td class="o2-namn"><%= Const.toHtml(o2.getString("namn")) %></td>
                        <td class="o2-best"><%= Const.getFormatNumber(o2.getDouble("best")) %></td>
                        <td class="o2-finns"><%= Const.noNull(o2.getDouble("ilager")).compareTo(0.0)>0 ? "*" : "" %></td>
                        <td class="o2-enh"><%= Const.toHtml(o2.getString("enh")) %></td>
                        <td class="o2-linje">______</td>
                    </tr>
                    <tr style="vertical-align: top; height: 20px; font-size: 12px;">
                        <td colspan="2" class=""><%= Const.toHtml(o2.getString("refnr")) %></td>
                        <td  class=""><%= Const.toHtml(o2.getString("plockinstruktion")) %></td>
                    </tr>
                </table>
            </td>
            </tr>
        <% } %>
        <% } %>
      </table>
  </div>
<% } %>        
        
</div>
<% } %>
