<%-- 
    Document   : index
    Created on : 2020-aug-23, 21:00:50
    Author     : ulf
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>PPG Info</title>
        <style>
            body {
                font-size: 30px;
                background: blue;
                margin: 8px;
            }
            .flexcontainer {
                display: flex;
                flex-wrap: wrap;
                flex-flow: column;
                justify-content: space-between;
                height: calc(100vh - 40px);
                width: 100%;
            }
            .flexrow1 {
                margin: 0px;
                padding: 0px;
            }
            .flexrow2 {
                height: 100%;
                width: 100%;
                margin: 0px;
                padding: 0px;
            }
            .ruta {
                border: 1px solid black;
                padding: 12px;
                background: white;
                margin: 12px;
                display: inline-block;
                width: 400px;
                min-height: 200px;
            }
            .ruta th {
                padding-right: 8px;
                font-weight: normal;
                font-size: 50%;
            }
            .ruta td {
                padding-right: 8px;
            }            
            h2 {
                font-weight: bold;
                font-size: 120%;
                margin: 0px;
                margin-bottom: 12px;
            }
            
        </style>
        <script>
var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      updateHtmlData(this.responseText);
    }
  };
  
  loadData();
  var loadDataInterval;
  loadDataInterval = setInterval(loadData, 1000*60);

function loadData() {
  xhttp.open("GET", "data", true);
  xhttp.send();
}
            
function updateHtmlData(injson) {
    var o = JSON.parse(injson);
  document.getElementById("ordrar").innerHTML = o.ordrar;
  document.getElementById("ordrarhotpick").innerHTML = o.ordrarhotpick;
  document.getElementById("ordrarhotpickdagens").innerHTML = o.ordrarhotpickdagens;
  document.getElementById("orderrader").innerHTML = o.orderrader;
  document.getElementById("hotpickorderrader").innerHTML = o.hotpickorderrader;
  document.getElementById("hotpickorderraderdagens").innerHTML = o.hotpickorderraderdagens;
  document.getElementById("plockadedagens").innerHTML = o.plockadedagens;
  document.getElementById("inlagradedagens").innerHTML = o.inlagradedagens;
  document.getElementById("plockade14dagarsnitt").innerHTML = o.plockade14dagarsnitt;
  document.getElementById("inlagrade14dagarsnitt").innerHTML = o.inlagrade14dagarsnitt;
  document.getElementById("plockade140dagarsnitt").innerHTML = o.plockade140dagarsnitt;
  document.getElementById("inlagrade140dagarsnitt").innerHTML = o.inlagrade140dagarsnitt;
  if (o.hotpickorderraderdagens>0 && flashVar==null) startFlash(); else  stopFlash();
}




    var flashVar = null;
    var flashColor=1;
function startFlash() {
    flashVar = setInterval(flash, 1000);
}
function stopFlash() {
    if (flashVar !== null) {
        clearInterval(flashVar);
        flashVar=null;
        document.body.style.background = "blue";
    }
}

function flash() {
    if (flashColor===1) {
        color = "red";
        flashColor=2;
    } else {
        color = "blue";
        flashColor=1;        
    }
    document.body.style.background = color;
}

setTimeout(function(){
   window.location.reload(1);
}, 1000*60*45);

//setInterval(reloadIntrainfo, 1000*60*30);
//function reloadIntrainfo() {
//    location.reload();
    //document.getElementById("intrainfo").src = document.getElementById("intrainfo").src;
//}



            </script>
        
    </head>
    <body>
        <div class="flexcontainer">
            <div class="flexrow1">
                <div style="margin: 12px; padding: 12px; background: white; height: 80px;">
                    <img style="margin-top: 12px" src="https://www.saljex.se/p/s300/logo-saljex.png">
                    <div style="float: right; margin-top: 12px;">
                        <iframe src='https://xn--vder24-bua.se/index.php/vader-widget/?widgettype=white&widgetcity=grums' title='Väderwidget' style='height:80px; min-width:200px; width:100%; max-width:100%;' name='weatheriFrame' scrolling='0' frameborder='0' ></iframe>        
                    </div>
                </div>
            </div>
            <div class="flexrow1">
                <div class="ruta">
                    <h2>Väntande ordrar</h2>
                    <table style="width: 100%">
                        <tr><th></th><th>Ordrar</th><th>Rader</th></tr>
                        <tr><td>Totalt</td><td><span id="ordrar"></td><td><span id="orderrader"></span></td></tr>
                        <tr><td>...varav Hotpick</td><td><span id="ordrarhotpick"></td><td><span id="hotpickorderrader"></span></td></tr>
                        <tr><td>...varav Hotpick idag</td><td><span id="ordrarhotpickdagens"></td><td><span id="hotpickorderraderdagens"></span></td></tr>
                    </table>
                </div>
                <div class="ruta">
                    <h2>Historik</h2>
                    <table style="width: 100%">
                        <tr><th></th><th>Plockat</th><th>Inlagrat</th></tr>
                        <tr><td>Dagens</td><td><span style="font-weight: bold;" id="plockadedagens"></span></td><td><span style="font-weight: bold;" id="inlagradedagens"></span></td></tr>
                        <tr><td>2 veckor</td><td><span id="plockade14dagarsnitt"></span></td><td><span id="inlagrade14dagarsnitt"></span></td></tr>
                        <tr><td>20 veckor</td><td><span id="plockade140dagarsnitt"></span></td><td><span id="inlagrade140dagarsnitt"></span></td></tr>
                    </table>
                </div>
            </div>
            <div class="flexrow2">
                <div style="background: white; margin: 12px; height: 100%">
                    <iframe id="intrainfo" style="width: 100%; height: 100%" src="https://docs.google.com/document/d/e/2PACX-1vRUWyVtyGk76_Y66WhapIKBnmwm23EGklsd9IDTkRmcDPqMRpm_YVxIiB7iv_2iT19ECYkMxjzU7Maw/pub?embedded=true"></iframe>
                </div>
            </div>
        </div>
            
        
    </body>
</html>
