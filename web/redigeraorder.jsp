<%-- 
    Document   : redigeraorder
    Created on : 2020-mar-06, 12:27:42
    Author     : ulf
--%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="se.saljex.wms.Const"%>
<%@page import="java.sql.Connection"%>
<%            
    Connection con=Const.getConnection(request); 
    String wmsordernr = (String)request.getParameter("wmsordernr");
%>
<%
    PreparedStatement ps;
    ResultSet o1;
    ResultSet o2;
%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Redigera order</title>
        <link rel="stylesheet" type="text/css" href="a.css">      
        <style>
            .odd {
                background-color: lightblue;
            }
            .even
            {
                background-color: lightgray;
            }
            .text {
                margin-bottom: 2px;
            }
            .orderrader {
                margin-top: 12px;
            }
            .orderhuvud {
                border: none;
            }
            .orderrader {
                border: none;
            }
            .tdrubrikrad {
                fons-size: 60%;
                font-weight: bold;
                background-color: grey;
            }
        </style>
        <%= Const.getBarcodeFontLinkHTML() %>
        
<script>
    function setFullevRad(row) {
        document.getElementById("i_bekraftat" + row).value = document.getElementById("bestantal" + row).innerHTML;
    }
    
    function sparaOrder() {
       var rowcn = 0;
       var inp;
       var err="";
       while (rowcn < 100000) {
           rowcn++;
           inp = document.getElementById("i_bekraftat" + rowcn);
           if (inp == null) break;
           var v = inp.value.replace(",",".").trim();
           if (isNaN(v) || v == null) err=err+"Rad " + rowcn + " ogiltigt antal.   ";
       }
       if (err.length > 0) alert("Kan inte spara. Följande fel behöver åtgärdas: " + err);
    }
    
    function deleteKolli(kolliid) {
        var xhttp = new XMLHttpRequest();
        xhttp.onreadystatechange = function() {
          if (this.readyState == 4 && this.status == 200) {
              document.getElementById("kollin").innerHTML = this.responseText;    
          }  };
        xhttp.open("GET", "/wms/ac?ac=deletekolli&kolliid=" + kolliid  , true);
        xhttp.send();
    }
    
    function addKolli() {
        var xhttp = new XMLHttpRequest();
        xhttp.onreadystatechange = function() {
          if (this.readyState == 4 && this.status == 200) {
              document.getElementById("kollin").innerHTML = this.responseText;    
          }  };
        xhttp.open("GET", "/wms/ac?ac=addkolli&wmsordernr=<%= wmsordernr %>" +
          "&kollityp=" + encodeURI(document.getElementById("kollityp").value) +
          "&antal=" + encodeURI(document.getElementById("antal").value) +
          "&viktkg=" + encodeURI(document.getElementById("viktkg").value) +
          "&langdcm=" + encodeURI(document.getElementById("langdcm").value) +
          "&breddcm=" + encodeURI(document.getElementById("breddcm").value) +
          "&hojdcm=" + encodeURI(document.getElementById("hojdcm").value)    
        , true);
        xhttp.send();
    }
</script>
            
        
        
    </head>
    <body>
<%
    ps = con.prepareStatement("select o1.*, k.tel as k_tel, k.biltel as k_biltel from " + 
           " wmsorder1 o1 left outer join kund k on k.nummer=o1.kundnr where o1.wmsordernr=?");
    ps.setString(1, wmsordernr);
    o1 = ps.executeQuery();
    ps = con.prepareStatement("select o2.*, l.ilager, l.lagerplats, a.refnr, a.plockinstruktion, s.finnsilager, ppg.quantityconfirmed, op.bekraftat as op_bekraftat from " + 
    " wmsorder2 o2 join wmsorder1 o1 on o1.wmsordernr=o2.wmsordernr  and o1.orgordernr=o2.orgordernr "
            + " left outer join lager l on l.artnr=o2.artnr and l.lagernr=o1.lagernr left outer join artikel a on a.nummer=o2.artnr "
            + " left outer join stjarnrad s on s.stjid=o2.stjid and o2.stjid>0 "
            + " left outer join (select masterordername, hostidentification, sum(quantityconfirmed::numeric) as quantityconfirmed from ppgorderpick where motivetype not in (1,3,5,6,10) group by masterordername, hostidentification) ppg on ppg.masterordername = o1.wmsordernr and ppg.hostidentification::numeric=o2.pos "
            + " left outer join wmsorderplock op on op.wmsordernr=o2.wmsordernr and op.pos=o2.pos "
            + " where o2.wmsordernr=? and o2.orgordernr= wmsordernr2int(?) order by pos",ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
    ps.setString(1, wmsordernr);
    ps.setString(2, wmsordernr);
    o2 = ps.executeQuery();
%>
<% if (o1.next()) { %>
<%    String logourl=Const.getLogoUrl(con, o1.getString("wmsdbschema")); %>
<div class="order">
  <div class="orderhuvud">
      <table>
          <tr>
              <td class="o1-r1c1">
                  <img src="<%= logourl %>">
              </td>
              <td class="o1-r1c2">REDIGERA ORDER</td>
              <td class="o1-r1c3">
                  Ordernr: <%= o1.getString("wmsordernr") %><br>
                  Datum: <%= o1.getString("datum") %>
              </td>
          </tr>
      </table>
      <table>
          <tr>
              <td class="o1-r2c1">
                  <div class="o1-rubrik">Kund</div>
                  <div class="o1-adrruta" style="padding: 4px;">
                  <%= Const.toHtml(o1.getString("namn")) %><br>
                  <%= Const.toHtml(o1.getString("adr1")) %><br>
                  <%= Const.toHtml(o1.getString("adr2")) %><br>
                  <%= Const.toHtml(o1.getString("adr3")) %>
                  </div>
              </td>
              <td class="o1-r2c2">
                  <div class="o1-rubrik">Leveransadress</div>
                  <div class="o1-adrruta <%= o1.getInt("annanlevadress")>0 ? "bold-border" : "" %>" style="padding: 4px;">
                  <%= Const.toHtml(o1.getString("levadr1")) %><br>
                  <%= Const.toHtml(o1.getString("levadr2")) %><br>
                  <%= Const.toHtml(o1.getString("levadr3")) %>
                  </div>
            </td>
          </tr>
      </table>
        <table>
            <tr>
                <td class="o1-r3c1" style="padding-top: 4px;">
                    <div class="o1-rubrik">Vår ref:</div>
                    <div class="text"><%= Const.toHtml(o1.getString("saljare")) %></div>
                    <div class="o1-rubrik">Er ref:</div>
                    <div class="text"><%= Const.toHtml(o1.getString("referens")) %></div>
                    <div class="o1-rubrik">Tel:</div>
                    <div class="text"><%= Const.toHtml(o1.getString("k_tel")) %> <%= Const.toHtml(o1.getString("k_biltel")) %></div>
                </td>
                <td class="o1-r3c2" style="padding-top: 4px;">
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
    <form>
        <input type="hidden" name="wmsordernr" value="<%= wmsordernr %>">

  <div class="orderrader">
      <table>
          <tr class="tdrubrikrad"><td>Lagerplats</td><td>Artikelnr</td><td>Benämning</td><td>Antal</td><td></td><td>Enh</td><td>I lager</td><td>Allokerat</td><td>Plockat</td><td>Bekräftat</td><td>Full</td></tr>
        <% StringBuilder sb = new StringBuilder(); %>
        <% boolean odd=false; %>
        <% int rowcn = 0; %>
        <% if (!Const.isEmpty(o1.getString("ordermeddelande"))) sb.append(Const.toHtml(o1.getString("ordermeddelande") + "<br>")); %>
        
        <% while (o2.next()) { %>
        <% if (!Const.isEmpty(o2.getString("text")) && Const.isEmpty(o2.getString("artnr"))) { %>
        <% sb.append(Const.toHtml(o2.getString("text")));
            sb.append("<br>");
        %>
        <% } else { %>
            <% odd=!odd; %>
            <% rowcn++; %>
            <tr class="<%= odd ? "odd" : "even" %>" style="vertical-align: middle; height: 2em">
                <td class=""><%= Const.toHtml(o2.getString("lagerplats")) %></td>
                <td class=""><%= Const.toHtml(o2.getString("artnr")) %></td>
                <td class=""><%= Const.toHtml(o2.getString("namn")) %></td>
                <td id="bestantal<%= rowcn %>" class=""><%= Const.getFormatNumber(o2.getDouble("best")) %></td>
                <td class=""><%= Const.noNull(o2.getDouble("ilager")).compareTo(0.0)>0 ? "*" : "" %></td>
                <td class=""><%= Const.toHtml(o2.getString("enh")) %></td>
                <td><%= Const.getFormatNumber(o2.getDouble("ilager")) %></td>
                <td class=""></td>
                <% Double quantityConfirmed = o2.getDouble("quantityconfirmed"); %>
                <% if (o2.wasNull()) quantityConfirmed=null; %>
                <td><%= quantityConfirmed!=null ? Const.getFormatNumber(quantityConfirmed) : "" %></td>
                <%
                    Double bekraftat;
                    bekraftat = o2.getDouble("op_bekraftat");
                    if (o2.wasNull()) bekraftat=null;
                    if (bekraftat==null && quantityConfirmed!=null) bekraftat=quantityConfirmed;
                %>
                
                <td><input id="i_bekraftat<%= rowcn %>" name="bekraftat<%= rowcn %>" value="<%= bekraftat==null ? "" : Const.getFormatNumber(bekraftat) %>" size="6"></td>
                <td>
                    <input type="button" value="&#10004;" onclick="setFullevRad(<%= rowcn %>)">
                    <input type="hidden" name="pos<%= rowcn %>" value="<%= o2.getInt("pos") %>">
                    <input type="hidden" name="ilager<%= rowcn %>" value="<%= Const.getFormatNumber(o2.getDouble("ilager")) %>">
                    <input type="hidden" name="best<%= rowcn %>" value="<%= Const.getFormatNumber(o2.getDouble("best")) %>">
                    <input type="hidden" name="artnr<%= rowcn %>" value="<%= Const.toHtml(o2.getString("artnr")) %>">
                </td>
            </tr>
        <% } %>
        <% } %>
      </table>
      <% if(sb.length()>0) { %>
        <div><%= sb.toString() %></div>
      <% } %>
  </div>
    </form>
  
  <div style="margin-top: 12px; text-align: right;">
      <input  onclick="sparaOrder()" style="background-color: lightgreen; height: 3em; font-weight: bold;" type="button" value="Spara ändringar">
  </div>        
        <div style="margin-top: 22px; padding-top: 8px; border-top: 1px solid black; ">
        Lägg till kolli
        <table>
            <tr><td>Kollityp</td><td>Antal</td><td>Vikt per kolli (kg)</td><td>Längd (cm)</td><td>Bredd (cm)</td><td>Djup (cm)</td><td></td></tr>
            <tr>
                <td><input type="text" id="kollityp" value="Kolli" list="kollityper" size="15"></td>
                <datalist id="kollityper">
                    <option value="Paket">
                    <option value="Ring">
                    <option value="Rör">
                    <option value="Häck">
                    <option value="Bunt">
                    <option value="Kolli">
                </datalist>

                <td><input type="text" id="antal" value="1" size="3"></td>
                <td><input type="text" id="viktkg" size="6"></td>
                <td><input type="text" id="langdcm" size="6"></td>
                <td><input type="text" id="breddcm" size="6"></td>
                <td><input type="text" id="hojdcm" size="6"></td>
                <td><input type="button" onclick="addKolli()" value="Lägg till kolli"</td>
            </tr>
        </table>
        

        </div>
        <DIV id="kollin">
            <% request.setAttribute("wmsordernr", wmsordernr); %>
            <jsp:include page="/WEB-INF/getkollilist.jsp" flush="true" />
        </DIV>   
<% } %>        
    </body>
</html>
