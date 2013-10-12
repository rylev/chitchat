var ws = new Object;
var user = new Object;
user.name = "Bob"

function send(message)
{
    ws.send(JSON.stringify({ info: { message: "message" , data: { user_name: user.name, chat_message: message}}}));
    console.log('Message sent');
}

function open()
{
    if (!("WebSocket" in window)) {
        alert("This browser does not support WebSockets");
        return;
    }
    ws = new WebSocket("ws://localhost:8080/chat");
    ws.onopen = function() { console.log('Connected'); };
    ws.onmessage = function (evt)
    {
      processMessage(evt);
    };
    ws.onclose = function()
    {
        console.log('Connection closed');
    };
}

function processMessage(evt)
{
    var receivedMsg = evt.data;
    console.log("Received: " + receivedMsg);

    var jsonObj = JSON.parse(receivedMsg);
    var keys = Object.keys(jsonObj)
    if(jsonObj.info.message == "connected") {
      processUserId(jsonObj);
    } else if(jsonObj.info.message = "message"){
      appendMessage(jsonObj.info.data);
    } else {
      console.log("Error! Receive unexpected message" + jsonObj);
    }
}

function processUserId(responseObj) {
  user["user_id"] = responseObj.info.data.user_id
  ws.send(JSON.stringify({ info: { message: "connected", data: { user_id: user.id, user_name: user.name }}}))
}

function appendMessage(messageData)
{
    var myDiv = document.createElement("div")
    myDiv.innerHTML = messageData.name + ": " + messageData.chat_message + "<br/>";

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
