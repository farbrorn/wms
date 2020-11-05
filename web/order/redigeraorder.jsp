<%-- 
    Document   : redigeraorder
    Created on : 2020-mar-06, 12:27:42
    Author     : ulf
--%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="se.saljex.wms.Const"%>
<%@page import="java.sql.Connection"%>
<%            
    Connection con=Const.getConnection(request); 
    Connection ppgcon=Const.getPPGConnection(request);
    String wmsordernr = (String)request.getParameter("wmsordernr");
    int lagernr = 0;
    try { lagernr=Integer.parseInt(request.getParameter("lagernr")); } catch (Exception e) {}
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
        <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
        <meta http-equiv="Pragma" content="no-cache" />
        <meta http-equiv="Expires" content="0" />        <title>Redigera order</title>
        <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/a.css">      
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
                font-size: 80%;
                font-weight: bold;
                background-color: grey;
            }
@media print {
    .no-print{
        display: none;
    }

        </style>
        <%= Const.getBarcodeFontLinkHTML() %>
        
<script>
    function setFullevRad(row) {
        document.getElementById("i_bekraftat" + row).value = document.getElementById("bestantal" + row).innerHTML;
    }
    function addSnabbRad(artnr) {
//        var anv = prompt("Bekräfta användare");
        var anv="00";
        var XHR= new XMLHttpRequest();
        XHR.addEventListener( "load", function(event) {
            try {
                var r = JSON.parse(event.target.responseText);
                if (r["response"]=="OK") location.reload(); else alert(r["errorMessage"]);
             } catch (ex) { alert("Kunde inte tolka svar från servern. (json): " + ex + " - Json: " + this.responseText); }
        } );
        XHR.addEventListener( "error", function( event ) { alert( 'Oops! Okänt fel. (XMLHttpRequest, eventlistener(error)' );} );    
        XHR.open( "POST", "<%= request.getContextPath() %>/ac?ac=addorderrad&wmsordernr=<%= wmsordernr %>&anvandare=" + encodeURIComponent(anv) + "&artnr=" + encodeURIComponent(artnr) );
        XHR.send();
    }
    
    function avbrytOrder() {
        if (!confirm("Vill du avbryta plock av denna order, och markera ordern som Sparad?")) return; 
        var anv = prompt("Bekräfta användare");
        if (anv!=null && anv.length > 0) {
            var XHR= new XMLHttpRequest();
            XHR.addEventListener( "load", function(event) {
                try {
                    var r = JSON.parse(event.target.responseText);
                    if (r["response"]=="OK") location.reload(); else alert(r["errorMessage"]);
                 } catch (ex) { alert("Kunde inte tolka svar från servern. (json): " + ex + " - Json: " + this.responseText); }
            } );
            XHR.addEventListener( "error", function( event ) { alert( 'Oops! Okänt fel. (XMLHttpRequest, eventlistener(error)' );} );    
            XHR.open( "POST", "<%= request.getContextPath() %>/ac?ac=avbrytwmsorder&wmsordernr=<%= wmsordernr %>&anvandare=" + encodeURIComponent(anv) );
            XHR.send();
        }
    }    

    function skrivutOrder() {
        window.open("<%= request.getContextPath() %>/vieworder.jsp?wmsordernr=<%= wmsordernr %>");
    }
    
    function fardigmarkeraOrder() {
        doSparaOrder(true);
    }
    function sparaOrder() { doSparaOrder(false); }

    function doSparaOrder(fardigmarkera) {
        var anv = prompt("Bekräfta användare");
        if (anv!=null && anv.length > 0) {
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
            if (err.length > 0) 
                alert("Kan inte spara. Följande fel behöver åtgärdas: " + err); 
            else {
                 var form=document.getElementById("oform");
                 var FD = new FormData(form);
                 var XHR= new XMLHttpRequest();
                 XHR.addEventListener( "load", function(event) {
                     try {
                             var r = JSON.parse(event.target.responseText);
                             if (r["response"]=="OK") {
                                 document.getElementById("message").innerHTML = '<p style="font-weight: bold; color: green;">Sparad OK!</p>'; 
                                 document.getElementById("hamtaordernr").value='';
                                 document.getElementById("hamtaordernr").focus();
                             } else {
                                 document.getElementById("message").innerHTML = '<p style="font-weight: bold; color: red;">' + r["errorMessage"] + '</p>'; 
                             }
                     } catch (ex) { alert("Kunde inte tolka svar från servern. (json): " + ex + " - Json: " + this.responseText); }
                 } );

                 XHR.addEventListener( "error", function( event ) { alert( 'Oops! Okänt fel. (XMLHttpRequest, eventlistener(error)' );} );    
                 XHR.open( "POST", "<%= request.getContextPath() %>/ac?ac=saveredigeradorder" );
     //            XHR.setRequestHeader("Content-Type","multipart/formdata; charset=utf-8");
                 if (fardigmarkera) {
                     FD.append("fardigmarkera","true");
                     FD.append("anvandare",anv);
                     FD.append("hindrasamfakstatus","false");                
                  }
                 XHR.send(FD);
             }
       }
    }
    
    function deleteKolli(kolliid) {
        var xhttp = new XMLHttpRequest();
        xhttp.onreadystatechange = function() {
          if (this.readyState == 4 && this.status == 200) {
              document.getElementById("kollin").innerHTML = this.responseText;    
          }  };
        xhttp.open("GET", "<%= request.getContextPath() %>/ac?ac=deletekolli&kolliid=" + kolliid  , true);
        xhttp.send();
    }
    
    function addKolli() {
        var xhttp = new XMLHttpRequest();
        xhttp.onreadystatechange = function() {
          if (this.readyState == 4 && this.status == 200) {
              document.getElementById("kollin").innerHTML = this.responseText;    
          }  };
        xhttp.open("GET", "<%= request.getContextPath() %>/ac?ac=addkolli&wmsordernr=<%= wmsordernr %>" +
          "&kollityp=" + encodeURI(document.getElementById("kollityp").value) +
          "&antal=" + encodeURI(document.getElementById("antal").value) +
          "&viktkg=" + encodeURI(document.getElementById("viktkg").value) +
          "&langdcm=" + encodeURI(document.getElementById("langdcm").value) +
          "&breddcm=" + encodeURI(document.getElementById("breddcm").value) +
          "&hojdcm=" + encodeURI(document.getElementById("hojdcm").value)    
        , true);
        xhttp.send();
    }
    function hamtaOrder() {
       var wmsordernr= document.getElementById("hamtaordernr").value;
       if (wmsordernr.size > 4) {
           document.getElementById("nyorderform").submit();
        }
    }
    function radUpp(currentRow) {
        if (currentRow > 1) {
            var nextInput = document.getElementById("i_bekraftat" + (currentRow-1));
            nextInput.focus();
            nextInput.select();
        }
    }
    function radNer(currentRow) {
        var nextInput = document.getElementById("i_bekraftat" + (currentRow+1));
        if (nextInput!=null) {
            nextInput.select();
            nextInput.focus();
        }
    }
    function bekraftatKeyHandler(event,currentRow) {
        var k = event.keyCode;
        if (k===13) { //enter
            event.preventDefault();
            radNer(currentRow);
        } else if (k==38) { //Upp
            event.preventDefault();
            radUpp(currentRow);
        } else if (k===40) { //Down
            event.preventDefault();
            radNer(currentRow);
        } else if (k==113) { //f2
            event.preventDefault();
            setFullevRad(currentRow);
            radNer(currentRow);
        } else if (k==121) { //f10
            event.preventDefault();
            sparaOrder();
        }
    }
    function kolliKeyHandler(event,prev,next) {
        var k = event.keyCode;
        if (k===13 || k===40) { //enter, down
            event.preventDefault();
            if (next!=null) document.getElementById(next).focus(); 
        } else if (k===38) { //up
            event.preventDefault();
            if (prev!=null) document.getElementById(prev).focus(); 
        } else if (k==121) { //f10
            event.preventDefault();
            addKolli();
        }
    }
    
    function documentKeyHandler(event) {
        var k = event.keyCode;
        if (k==114) { //f3
            event.preventDefault();
            skrivutOrder();
        }        
    }
</script>
            
        
        
    </head>
    <body onkeydown="documentKeyHandler(event)">
        <div class="no-print" id="message"></div>
        <div class="no-print" id="nyordernr" style="margin: 8px 0px 8px 0px; border: 1pk solid black; padding: 8px;">
            <form id="nyorderform">
                Hämta order: <input id="hamtaordernr" name="wmsordernr">
                <button onclick="hamtaOrder()">Hämta</button>
            </form> 
        </div>
        <div>Pil upp/ner, Enter - Byt inmatningsfält.  F2 - Kopiera antal. F3 - Skriv ut. F10 - Spara.</div>
<%
    ps = con.prepareStatement("select o1.*, k.tel as k_tel, k.biltel as k_biltel from " + 
           " wmsorder1 o1 left outer join kund k on k.nummer=o1.kundnr where o1.wmsordernr=?");
    ps.setString(1, wmsordernr);
    o1 = ps.executeQuery();
    ps = con.prepareStatement("select o2.*, l.ilager, l.lagerplats, a.refnr, a.plockinstruktion, s.finnsilager, ppg.quantityconfirmed, op.bekraftat as op_bekraftat from " + 
    " wmsorder2 o2 join wmsorder1 o1 on o1.wmsordernr=o2.wmsordernr  and o1.orgordernr=o2.orgordernr "
            + " left outer join lager l on l.artnr=o2.artnr and l.lagernr=o1.lagernr left outer join artikel a on a.nummer=o2.artnr "
            + " left outer join stjarnrad s on s.stjid=o2.stjid and o2.stjid>0 "
            + " left outer join (select masterordername, hostidentification, sum(quantityconfirmed::numeric) as quantityconfirmed from ppgorderpick where motivetype not in (3,5,6,10) group by masterordername, hostidentification) ppg on ppg.masterordername = o1.wmsordernr and ppg.hostidentification::numeric=o2.pos "
//            + " left outer join wmsorderplock op on op.wmsordernr=o2.wmsordernr and op.pos=o2.pos "
            + " where o2.wmsordernr=? and o2.orgordernr= wmsordernr2int(?) order by pos",ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
    ps.setString(1, wmsordernr);
    ps.setString(2, wmsordernr);
    o2 = ps.executeQuery();
    

    HashMap<Integer, String> lagerplatser = new HashMap<Integer, String>();
    try { //PPG-connection kan vara null eller krångla, och då bryter vi bara tyst
        PreparedStatement ppgPs = ppgcon.prepareStatement(
                "select * from (\n" +
           "SELECT 'Work' as typ, wo.WorkorderName as wmsordernr, ml.Hostidentification, mb.MaterialName, wl.Quantity, l.LocationName FROM WORKORDERLINE WL JOIN Workorder WO ON WO.WorkorderId = WL.WorkorderId\n" +
           "JOIN LocContentbreakdown LB on lb.LocContentbreakdownId = wl.LocContentbreakdownId\n" +
           "join Materialbase mb on mb.MaterialId = wl.MaterialId\n" +
           "join LocContent lc on lc.LocContentId=lb.LocContentId\n" +
           "join Location l on l.LocationId = lc.LocationId\n" +
           "join Masterorderline ml on ml.MasterorderlineId = wl.MasterorderlineId\n" +
           "union all\n" +
           "select 'History' as typ, h.MasterorderName ,hl.Hostidentification, h.MaterialName, h.QuantityConfirmed, picklocationname \n" +
           "from History h \n" +
           "join HistoryMasterorderline hl on hl.HistMasterorderlineId = h.HistMasterorderlineId\n" +
           "where h.MotiveType=0\n" +
           ") a \n" +
           "where wmsordernr=?\n" +
           "order by Hostidentification"
        );
        ppgPs.setString(1, wmsordernr);
        ResultSet ppgRs  = ppgPs.executeQuery();
        while(ppgRs.next()) {
            String s = lagerplatser.get(ppgRs.getInt("hostidentification"));
            if (s==null ) s=""; else s=s+"<br>";
            s=s+Const.toHtml(ppgRs.getString("quantity") + " / " + ppgRs.getString("locationname"));
            lagerplatser.put(ppgRs.getInt("hostidentification"), s);
        }

    } catch (Exception e) { 
        Const.log("Fel vid utskrift av lagerplatser (ppg-connection)." + e.getMessage()); 
    }

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
                    <div class="o1-rubrik">Status:</div>
                    <div class="text">
                        <%= Const.toHtml(o1.getString("status")) %>
                    </div>
                </td>
            </tr>
        </table>
  </div>
                    <form id="oform" method="post" enctype="application/x-www-form-urlencoded">
                        <input type="hidden" name="wmsordernr" value="<%= wmsordernr %>">

  <div class="orderrader">
      <table>
          <tr class="tdrubrikrad"><td>Lagerplats</td><td>Artikelnr</td><td>Benämning</td><td>Antal</td><td></td><td>Enh</td><td>I lager</td><td>Allokerat</td><td>Bekräftat</td><td>Full</td></tr>
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
                <td class="" style="font-size: 80%">
                    <% String s = lagerplatser.get(o2.getInt("pos")); %>
                    <%= s!=null ? s : Const.toHtml(o2.getString("lagerplats"))   %>
                </td>
                <td class=""><%= Const.toHtml(o2.getString("artnr")) %></td>
                <td class=""><%= Const.toHtml(o2.getString("namn")) %></td>
                <td id="bestantal<%= rowcn %>" class="" style="font-weight: bold"><%= Const.getFormatNumber0To2Dec(o2.getDouble("best")) %></td>
                <td class=""><%= Const.noNull(o2.getDouble("ilager")).compareTo(0.0)>0 ? "*" : "" %></td>
                <td class=""><%= Const.toHtml(o2.getString("enh")) %></td>
                <td><%= Const.getFormatNumber0To2Dec(o2.getDouble("ilager")) %></td>
                <% Double quantityConfirmed = o2.getDouble("quantityconfirmed"); %>
                <% if (o2.wasNull()) quantityConfirmed=null; %>
                <%
                    Double bekraftat;
                    bekraftat = o2.getDouble("op_bekraftat");
                    if (o2.wasNull()) bekraftat=null;
                    if (bekraftat==null && quantityConfirmed!=null) bekraftat=quantityConfirmed;
                %>
                <td class=""><%= bekraftat==null ? "" : Const.getFormatNumber0To2Dec(bekraftat) %></td>
                
                <td><input onkeydown="bekraftatKeyHandler(event,<%= rowcn  %>)" <%=  rowcn==1 ? "autofocus" : "" %> style="width: 4em; height: 1.3em;" id="i_bekraftat<%= rowcn %>" name="bekraftat<%= rowcn %>" value="" ></td>
                <td>
                    <input class="no-print" type="button" value="&#10004;" onclick="setFullevRad(<%= rowcn %>)">
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
  
  <div class="no-print" style="margin-top: 12px; ">
      <% 
          ResultSet rsSnabb = con.createStatement().executeQuery("select a.nummer, a.namn from wmssnabbartiklar sa join artikel a on a.nummer=sa.artnr where sa.typ='redigeraorder' order by sortorder");
          while (rsSnabb.next()) {              %>
              <button style="margin: 0px 4px 0px 4px;" onclick="addSnabbRad('<%= rsSnabb.getString("nummer") %>')"><%= Const.toHtml(rsSnabb.getString("namn")) %></button>
    <% } %>
  </div>        
  <div class="no-print" style="margin-top: 12px; text-align: right;">
      <input  onclick="avbrytOrder()" style="background-color: lightred; height: 2em; font-weight: normal;" type="button" value="Avbryt order" title="Avbryter hanteringen av order, nollställer alla plock och kollin samt sätter status Sparad.">
      <input  onclick="skrivutOrder()" style="height: 2em; font-weight: normal;" type="button" value="Skriv ut">
      <input  onclick="fardigmarkeraOrder()" style="background-color: lightgreen; height: 2em; font-weight: normal;" type="button" value="Färdigmarkera order" title="Markera ordern som färdiplockad och klar för lastning och fakturering.">
      <input  onclick="sparaOrder()" style="background-color: lightgreen; height: 3em; font-weight: bold;" type="button" value="Spara ändringar">
  </div>        
  <div style="margin-top: 22px; font-weight: bold; ">Kollin</div>
  <div class="no-print" style="padding-top: 8px;  ">
        <table>
            <tr><td>Kollityp</td><td>Antal</td><td>Vikt per kolli (kg)</td><td>Längd (cm)</td><td>Bredd (cm)</td><td>Djup (cm)</td><td></td></tr>
            <tr>
                <td><input onkeydown="kolliKeyHandler(event,null, 'antal')" type="text" id="kollityp" value="Kolli" size="15">
                    <select style="width: 20px;" onchange="document.getElementById('kollityp').value=this.options[this.selectedIndex].text;">
                        <option value="Paket">Paket</option>
                        <option value="Pall">Pall</option>
                        <option value="Ring">Ring</option>
                        <option value="Rör">Rör</option>
                        <option value="Häck">Häck</option>
                        <option value="Bunt">Bunt</option>
                        <option value="Kolli">Kolli</option>
                    </select>
                </td>

                <td><input type="text" id="antal" value="1" size="3" onkeydown="kolliKeyHandler(event,'kollityp', 'viktkg')"></td>
                <td><input type="text" id="viktkg" size="6" onkeydown="kolliKeyHandler(event,'antal','langdcm')"></td>
                <td><input type="text" id="langdcm" size="6" onkeydown="kolliKeyHandler(event,'viktkg','breddcm')"></td>
                <td><input type="text" id="breddcm" size="6" onkeydown="kolliKeyHandler(event,'langdcm', 'hojdcm')"></td>
                <td><input type="text" id="hojdcm" size="6" onkeydown="kolliKeyHandler(event,'breddcm','addkolli')"></td>
                <td><input type="button" id="addkolli" onclick="addKolli()" value="Lägg till kolli" ></td>
            </tr>
        </table>
        

        </div>
        <DIV id="kollin" style="margin-top: 12px;">
            <% request.setAttribute("wmsordernr", wmsordernr); %>
            <jsp:include page="/WEB-INF/getkollilist.jsp" flush="true" />
        </DIV>
</div>
<% } %>  


<div class="no-print" style="display: inline-block">
    <%
        ResultSet rs = con.createStatement().executeQuery("select wmsordernr, namn from wmsorder1 where lagernr=" + lagernr + " and status='Utskr' order by wmsordernr");
        while (rs.next()) {
    %>
    <div>
        <a href="?wmsordernr=<%= rs.getString("wmsordernr") %>">
           <%= rs.getString("wmsordernr")  %>
            <%= Const.toHtml(rs.getString("namn")) %>
        </a>
        
    </div>
    
  <% } %>
</div>




    </body>
</html>
