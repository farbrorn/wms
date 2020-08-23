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
            }
        </style>
        <script>
var source = new EventSource("data");
source.addEventListener("data", 
function(event) {
    var o = JSON.parse(event.data);
  document.getElementById("ordrar").innerHTML = o.ordrar;
  document.getElementById("ordrarhotpick").innerHTML = o.ordrarhotpick;
  document.getElementById("ordrarhotpickdagens").innerHTML = o.ordrarhotpickdagens;
  document.getElementById("orderrader").innerHTML = o.orderrader;
  document.getElementById("hotpickorderrader").innerHTML = o.hotpickorderrader;
  document.getElementById("hotpickorderraderdagens").innerHTML = o.hotpickorderraderdagens;
  document.getElementById("plockadedagens").innerHTML = o.plockadedagens;
  document.getElementById("inlagradedagens").innerHTML = o.inlagradedagens;
  document.getElementById("plockade10dagar").innerHTML = o.plockade10dagar;
  document.getElementById("inlagrade10dagar").innerHTML = o.inlagrade10dagar;
  document.getElementById("plockade100dagar").innerHTML = o.plockade100dagar;
  document.getElementById("inlagrade100dagar").innerHTML = o.inlagrade100dagar;
  document.getElementById("i").innerHTML = o.i;
  if (o.hotpickorderraderdagens>0 && flashVar==null) startFlash(); else if (o.hotpickorderraderdagens===0 && flashVar != null) stopFlash();
}, false);            

    var flashVar = null;
    var flashColor=1;
function startFlash() {
    flashVar = setInterval(flash, 1000);
}
function stopFlash() {
    clearInterval(flashVar);
    flashVar=null;
    document.body.style.background = "white";
}

function flash() {
    if (flashColor===1) {
        color = "red";
        flashColor=2;
    } else {
        color = "white";
        flashColor=1;        
    }
    document.body.style.background = color;
}
            </script>
        
    </head>
    <body>
        Ordrar att plocka:<span id="ordrar"></span>
        <br>...varav hotpick:<span id="ordrarhotpick"></span>
        <br>...varav hotpick idag:<span id="ordrarhotpickdagens"></span>
        <br>Orderrader att plocka:<span id="orderrader"></span>
        <br>...varav hotpick:<span id="hotpickorderrader"></span>
        <br>...varav hotpick idag:<span id="hotpickorderraderdagens"></span>
        <br>
        <br>Plockade orderrader:<span id="plockadedagens"></span>
        <br>Plockade orderrader 10 dagar:<span id="plockade10dagar"></span>
        <br>Plockade orderrader 100 dagar:<span id="plockade100dagar"></span>
        <br>
        <br>Inlagrade orderrader:<span id="inlagradedagens"></span>
        <br>Inlagrade orderrader 10 dagar:<span id="inlagrade10dagar"></span>
        <br>Inlagrade orderrader 100 dagar:<span id="inlagrade100dagar"></span>
        <br>i:<span id="i"></span>
                       </body>
</html>
