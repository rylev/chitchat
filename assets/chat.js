var ws = new Object;
var user = new Object;

function send(message)
{
    jsonString = JSON.stringify({ type: "chat_message" , user_name: user.name, message_text: message});
    ws.send(jsonString);
    console.log('Message "'+ message + '" sent');
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
    if(jsonObj.type == "connected") {

      processUserId(jsonObj);
    } else if(jsonObj.type == "message"){

      appendMessage(jsonObj);
    } else {

      console.log("Error! Receive unexpected message" + jsonObj);
    }
}

function processUserId(jsonObj)
{
  user.id = jsonObj.user_id
  jsonString = JSON.stringify({ type: "connected", user_id: user.id, user_name: user.name })
  ws.send(jsonString)
}

function appendMessage(messageData)
{
    var myDiv = document.createElement("div")
    myDiv.innerHTML = messageData.name + ": " + messageData.message_text + "<br/>";

    $('#msgs').append(myDiv);
}

function registerEvents()
{
  $('#set-name').click(function(evt){
    var name = $('#name').val();
    user.name = name;
    open();
    $('#name-setting').hide();
    $('#chat').show();
  });

  $('#send').click(function(evt){
    var message = $('#message').val();
    send(message);
  });
}

$( document ).ready(function() {

  $('#chat').hide();
  registerEvents();
});
