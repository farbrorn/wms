<%-- 
    Document   : index
    Created on : 2019-maj-28, 20:52:52
    Author     : ulf
--%>
<%@page import="se.saljex.wms.OrderGrupper.OrderGrupp"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="se.saljex.wms.Const"%>
<%@page import="java.sql.Connection"%>

<%
    String bildurl = Const.getBildUrl();
    String logourl="https://www.saljex.se/p/s200/logo-saljex";
    Integer lagernr=0;
//    Integer ordernr=null;
//    try { ordernr=Integer.parseInt(request.getParameter("ordernr")); } catch (Exception e) {}
    String visaOrderStatus="Sparad";
    String visaOrderGrupp=request.getParameter("ordergrupp");
    boolean visaUtskrivna="true".equals(request.getParameter("visautskrivna"));
    boolean visaSamfakt="true".equals(request.getParameter("visasamfakt"));
    boolean visaAvvaktande="true".equals(request.getParameter("visaavvaktande"));
    
%>
<%
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
        <title>Order</title>
        <%= Const.getBarcodeFontLinkHTML() %>
        <link rel="stylesheet" type="text/css" href="a.css">            
        <style>
            .trselected {
                background-color: lightgrey;
            }
            
        </style>
        <script>
            var visadOrder;
                var timerCn;
                var timerStartValue;
                
            function sendForm() {
                document.getElementById("form").submit();
            }
            function sendFormOrdergrupp(orderGrupp) {
                document.getElementsByName("ordergrupp")[0].value=orderGrupp;
                sendForm();
            }
            
            function resetTimer() {
                timerCn=100;
                timerStartValue=timerCn;
            }
            function timerCount() {
                timerCn--;
                if (timerCn<=0) location.reload();
                var proc;
                proc = (timerStartValue-timerCn)/timerStartValue*100;
                document.getElementById("updatebar").style.width=proc+'%';
            }
            function load() {
                document.getElementById("ordertable").rows[0].focus();
                resetTimer();
                window.setInterval(timerCount,1000); 
//                document.addEventListener("mousemove", resetTimer(), false);
//                document.addEventListener("mousedown", resetTimer(), false);
//                document.addEventListener("keypress", resetTimer(), false);
//                document.addEventListener("touchmove", resetTimer(), false);
                
                window.setTimeout(function() {
                    window.setInterval(function() {
                        var f = document.getElementById("uppdatera");
                        f.style.color = (f.style.color != 'black' ? 'black' : 'red'); 
                    }, 1000)
                }, 5*60*1000);
            }
            
            function visaSnabbrader(ordernr) {
        //        resetTimer();
                if (visadOrder) {
                    if (visadOrder!=ordernr) resetTimer();
                    document.getElementById("trsnabbrader"+visadOrder).classList.remove("trselected");
                }
                document.getElementById("trsnabbrader"+ordernr).classList.add("trselected");
                document.getElementById("snabbrader").innerHTML = document.getElementById("snabbrader" + ordernr).innerHTML;
                visadOrder=ordernr;
            }
            
            function orderlistKey(event) {
                var c = document.activeElement.rowIndex;
                var len = document.activeElement.parentElement.rows.length;
                if (event.keyCode==40 ) {
                    if (c<len-1) {
                        document.activeElement.parentElement.rows[c+1].focus();
                        event.preventDefault();
                    }
                } else if (event.keyCode==38) {
                    if (c>0) {
                        document.activeElement.parentElement.rows[c-1].focus();
                        event.preventDefault();
                    }
                }
            }
            
            function visaOrder() {
                window.open("<%= request.getContextPath() %>/vieworder.jsp?ordernr="+visadOrder);
            }
function skickaTillPlock() {
     
    var anv = prompt("Bekräfta användare");
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
        try {
      var r = JSON.parse(this.responseText);
      
    if (r["response"]=="OK") {
        window.open("<%= request.getContextPath() %>/printorder.jsp?ordernr="+visadOrder);
    } else {
        alert(r["errorMessage"]);
    }
    
            } catch (ex) {
                alert("Kunde inte tolka svar från servern. (json): " + ex + " - Json: " + this.responseText);
            }
    }
  };
  xhttp.open("GET", "/wms/ac?ac=markorderwms&ordernr=" + visadOrder + "&anvandare=" + encodeURIComponent(anv), true);
  xhttp.send();
}
            </script>
    </head>
    <body onload="load()">
        
        <div class="sidhuvud">
            <div style="font-size: 26px; font-weight: bold; margin-bottom: 10px;">Dagens order <span style="font-size: 12px;"><a href="printorderform.jsp" target="_blank">Snabbutskrift</a></span></div>
            <div>
                <form id="form">
                    <button onclick="sendForm()" style="width:100px; height: 22px; margin-right: 24px; padding: 0;">
                    <div  style="display: block; position: relative; width:100%; height: 100%; ">
                        <span style="width: 100%; height: 100%; position: absolute; top: 0; left:0; z-index: 10;" id="uppdatera" >Uppdatera</span>
                        <div id="updatebar" style="display: block; height: 100%; position: absolute; top: 0; left:0; width:0%;  background-color: lightgreen;"></div>
                    </div>
                        </button>
                Visa Utskrivna:<input onclick="sendForm()" type="checkbox" name="visautskrivna" value="true" <%= visaUtskrivna ? "checked" : "" %>>
                Samfakt:<input onclick="sendForm()" type="checkbox" name="visasamfakt" value="true" <%= visaSamfakt ? "checked" : "" %>>
                Avvaktande:<input onclick="sendForm()" type="checkbox" name="visaavvaktande" value="true" <%= visaAvvaktande ? "checked" : "" %>>
                <input type="hidden" name="ordergrupp" value="<%= request.getParameter("ordergrupp") %>">
                </form>
            </div>
            
        </div>       
        
        
                
        
        <%
            int antalStatusar=1;
            if (visaAvvaktande) antalStatusar++;
            if(visaUtskrivna) antalStatusar++;
            if(visaSamfakt) antalStatusar= antalStatusar+2;
            String statusarInString = "?";
            for (int i=1; i<antalStatusar; i++) statusarInString = statusarInString + ",?";
            
     q = "select fraktbolag, count(distinct wmsordernr) as antal from (select \n" +
"o1.wmsordernr,\n" + Const.getSQLTransportorOmkodad("fraktbolag", "tl1.linjenr") + " as fraktbolag,\n" +
"tl1.namn t1_namn, tl1.d1 as t1_d1, tl1.d2 as t1_d2, tl1.d3 as t1_d3, tl1.d4 as t1_d4,  tl1.d5 as t1_d5\n" +
"\n" +
" from wmsorder1 o1 " +
"left outer join turlinje tl1 on (tl1.linjenr=o1.linjenr1 or tl1.linjenr=o1.linjenr2 or tl1.linjenr=o1.linjenr3) and tl1.franfilial=o1.lagernr\n" +
"where  lagernr=? and o1.status in (" + statusarInString + ") ) o \n" +

"group by fraktbolag order by fraktbolag\n";
     
   ps=con.prepareStatement(q);  
   int pos=1;  
   ps.setInt(pos, lagernr);
   pos++;
   ps.setString(pos, visaOrderStatus);
   pos++;
   if (visaSamfakt) { 
        ps.setString(pos, "Samfak");
        pos++;
        ps.setString(pos, "Hämt");
        pos++;
   }    
   if (visaUtskrivna) { 
        ps.setString(pos, "Utskr");
        pos++;
   }    
   if (visaAvvaktande) { 
        ps.setString(pos, "Avvakt");
        pos++;
   }    
   rs = ps.executeQuery();
   %>
   <div class="ordergrupper">
       <div STYLE="font-weight: bold; margin-bottom: 6px;">Grupper</div>
   <table>
    <% while(rs.next()) {        %>
    <% if (visaOrderGrupp==null) visaOrderGrupp=rs.getString("fraktbolag"); %>
    <tr class="link <%= Const.toStr(rs.getString("fraktbolag")).equals(visaOrderGrupp) ? " trselected" : "" %>">
        <td class="og-ordergrupp"><a onclick="sendFormOrdergrupp('<%= rs.getString("fraktbolag") %>')" vhref="?ordergrupp=<%= Const.urlEncode(rs.getString("fraktbolag")) %>"> <%= Const.toHtml(rs.getString("fraktbolag")) %></a> </td>
        <td class="og-antal"><%= rs.getInt("antal") %> </td>
    </tr>    
    <% } %>
    </table>    
   </div>    
    
    
    
    
    
    
    
    <%
      q = "select o1.wmsordernr as ordernr, o1.datum,   o1.namn, o1.status, " + 
              " sum(case when o2.best > 0 then 1 else 0 end) as rader, o1.levdat, " +
              " sum(case when (o2.best > 0 and l.ilager > 0) or (s.finnsilager>0) then 1 else 0 end) as raderilager " +
              " from wmsorder1 o1 " +
        "left outer join turlinje tl1 on (tl1.linjenr=o1.linjenr1 or tl1.linjenr=o1.linjenr2 or tl1.linjenr=o1.linjenr3) and tl1.franfilial=o1.lagernr " +
             " left outer join wmsorder2 o2 on o1.wmsordernr=o2.wmsordernr and o1.orgordernr=o2.orgordernr " + 
             " left outer join lager l on l.artnr=o2.artnr and l.lagernr=o1.lagernr " + 
             " left outer join stjarnrad s on s.stjid=o2.stjid and o2.stjid>0 " +
              " where  o1.lagernr=? and o1.status in (" + statusarInString + ") " +
              " and " + Const.getSQLTransportorOmkodad("fraktbolag", "tl1.linjenr") + "  = ? " +
              " group by o1.namn, o1.wmsordernr, o1.datum, o1.status, o1.levdat " +
              " order by case when o1.status='Sparad' then '0' else o1.status end, o1.status, case when o1.levdat is null then current_date else o1.levdat end, o1.wmsordernr desc"
              ;
   ps = con.prepareStatement(q);
   pos=1;
   ps.setInt(pos, lagernr);
   pos++;
   ps.setString(pos, visaOrderStatus);
   pos++;
  if (visaSamfakt) { 
        ps.setString(pos, "Samfak");
        pos++;
        ps.setString(pos, "Hämt");
        pos++;
   }    
   if (visaUtskrivna) { 
        ps.setString(pos, "Utskr");
        pos++;
   }    
   if (visaAvvaktande) { 
        ps.setString(pos, "Avvakt");
        pos++;
   }    
   ps.setString(pos, visaOrderGrupp);
   pos++;
   rs = ps.executeQuery();
      int rader;
      int raderIlager;
      int proc;
        %>
        <div class="orderlista">
            <div style="font-weight: bold; margin-bottom: 6px;">Order Grupp: <%= Const.toHtml(visaOrderGrupp) %></div>
        <table id="ordertable">
            <tr>
                <td class="o-ordernr">Order/Datum</td>
                <td class="o-datum"></td>
                <td class="o-namn">Kund</td>
                <td>Lager/Lev.datum</td>
                
            </tr>
            <% int tabindex=0; %>
            <% while (rs.next()) { %>
            <% 
                tabindex++;
                rader = rs.getInt("rader");
                raderIlager = rs.getInt("raderilager");
                if (rader==0) proc=100;
                else if (raderIlager==0) proc=0;
                else proc=(int)((double)raderIlager/(double)rader*100);
                
                
            %>
                <tr class="link" id="trsnabbrader<%= rs.getString("ordernr") %>" onkeydown="orderlistKey(event)" tabindex="<%= tabindex %>" onfocus="visaSnabbrader('<%= rs.getString("ordernr") %>')" onclick="visaSnabbrader('<%= rs.getString("ordernr") %>')">
                    <td class="o-ordernr"> <%= rs.getString("ordernr") %><br><%= rs.getString("datum") %> </td>
                <td class="o-datum"><%= rs.getString("status") %></td>
                <td class="o-namn"><%= Const.toHtml(rs.getString("namn")) %></td>
                <td><div style="width: 100px; height: 20px; text-align: center; overflow: visible; white-space: nowrap; border: 1px solid grey; position:relative;"><div style="top: 0; left:0; position: absolute; line-height: 20px; width: 100%; height: 100%; text-align: center; z-index: 10;"><%= raderIlager %>/<%= rader %></div><div style="background-color: lightgreen; position: absolute; top: 0; left: 0; height: 100%; width:<%= proc %>%"></div></div><b><%= Const.toStr(rs.getString("levdat")) %></b></td>
                <td style="display: none" id="snabbrader<%= rs.getString("ordernr") %>">
                    <% request.setAttribute("ordernr", rs.getString("ordernr")); %>
                    <jsp:include page="/WEB-INF/getorderrader.jsp" flush="true" />
                </td>

            </tr></aaa>
            <% } %>
        </table>    
        </div>

        
    <div class="order-snabbrader" >
        <div style="margin-bottom: 6px;" class="order-knappar">
            <button onclick="skickaTillPlock()">Skicka till plock</button>
            <button onclick="visaOrder()">Visa order</button>
        </div>
        <div id="snabbrader">
        </div>
    </div>
        
   </body>
</html>
