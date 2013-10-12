var ws = new Object;

function send(message)
{
    ws.send(message);
    console.log('Message sent');
}

function open()
{
    if (!("WebSocket" in window)) {
        alert("This browser does not support WebSockets");
        return;
    }
    ws = new WebSocket("ws://localhost:8080/chat");
    console.log(ws);
    ws.onopen = function() { console.log('Connected'); };
    ws.onmessage = function (evt)
    {
      appendMessage(evt);
    };
    ws.onclose = function()
    {
        console.log('Connection closed');
    };
}

function appendMessage(evt)
{
    var receivedMsg = evt.data;
    var myDiv = document.createElement("div")
    myDiv.innerHTML = "User: " + receivedMsg + "<br/>";

    console.log("Received: " + receivedMsg);
    $('#msgs').append(myDiv);
}

function registerEvents()
{
  $('#send').click(function(evt){
    console.log("Click");
    var message = $('#message').val();
    send(message);
  });
}

document.onload = open();
$( document ).ready(function() {
  registerEvents();

});
