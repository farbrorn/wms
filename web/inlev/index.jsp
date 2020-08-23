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
        <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
        <meta http-equiv="Pragma" content="no-cache" />
        <meta http-equiv="Expires" content="0" />        
        <title>Inleverans</title>
        <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/a.css">            
        <style>
        </style>
        <script>
            function toggleRow(r) {
               var x = document.getElementById("r"+r);
                if (x.style.display === "none") {
                    x.style.display = "table-row";
                  } else {
                    x.style.display = "none";
                  }               
            }
            
function overfor(id) {
    var anv = prompt("Bekräfta användare");
    if (anv!=null && anv.length > 0) {
        var xhttp = new XMLHttpRequest();
        xhttp.onreadystatechange = function() {
          if (this.readyState == 4 && this.status == 200) {
              try {
            var r = JSON.parse(this.responseText);

          if (r["response"]=="OK") {
              alert("Skickad till inplock.");
              location.reload();
          } else {
              alert(r["errorMessage"]);
          }
                  } catch (ex) {
                      alert("Kunde inte tolka svar från servern. (json): " + ex + " - Json: " + this.responseText);
                  }
          }
        };
        xhttp.open("GET", "/wms/ac?ac=markinlevwms&wmsordernr=IN-" + id + "&anvandare=" + encodeURIComponent(anv), true);
        xhttp.send();
    }
}
            </script>
    </head>
    <body>
        <h1>För över inleverans</h1>
        <table>
            <tr style="font-weight: bold;"><td style="width:4em;">Bestnr</td><td style="width:4em;">ID</td><td style="width:6em;">Datum</td><td style="width:8em;">Levnr</td><td style="width:15em;">Levnamn</td><td></td></tr>
        <%
            q="select i1.id, i1.bestnr, i1.datum, i1.levnr, l.namn as levnamn, i1.marke , i2.artnr, i2.artnamn, i2.antal, i2.enh "+
                " from inlev1 i1 join inlev2 i2 on i1.id=i2.id left outer join lev l on l.nummer=i1.levnr  "+
                " where i1.status = 'Sparad' and i1.ordernr=0 and i1.lagernr=? and i1.datum > current_date-30 "+
                " order by i1.bestnr desc, i1.id desc, i2.rad ";
            ps = con.prepareStatement(q);
            ps.setInt(1, lagernr);
            rs = ps.executeQuery();
            int currId=0;
            boolean odd=false;
            int cn=0;
            while (rs.next()) {
            %>
            <% if (currId == 0 || currId!=rs.getInt("id")) { %>
                <% if (currId != 0) { %>
                    </table></td></tr>
                <% } %>
                <% odd = !odd; %>
                <% cn++; %>
                <% currId = rs.getInt("id"); %>
                <tr class="<%= odd ? "odd" : "even" %>" style="font-weight: bold;">
                    <td><%= rs.getInt("bestnr") %></td>
                    <td><%= rs.getInt("id") %></td>
                    <td><%= rs.getString("datum") %></td>
                    <td><%= Const.toHtml(rs.getString("levnr")) %></td>
                    <td><%= Const.toHtml(rs.getString("levnamn")) %></td>
                    <td><button onclick="overfor(<%= rs.getInt("id") %>)">Överför</button><a onclick="toggleRow(<%= cn %>)">Visa</a></td>
                </tr>
                <tr id="r<%= cn %>" style="display: none" class="<%= odd ? "odd" : "even" %>"><td></td><td colspan="5"><table>
                            <colgroup>
                                <col style="width: 8em;">
                                <col style="width: 24em;">
                                <col style="width: 4em;">
                                <col style="width: 3em;">
                            </colgroup>
            <% } %>
            <tr>
                <td><%= Const.toHtml(rs.getString("artnr")) %></td>
                <td><%= Const.toHtml(rs.getString("artnamn")) %></td>
                <td style="text-align: right;"><%= Const.getFormatNumber0To2Dec(rs.getDouble("antal")) %></td>
                <td><%= Const.toHtml(rs.getString("enh")) %></td>
            </tr>
            
        <% } %>
        </table></td></tr></table>
   </body>
</html>
