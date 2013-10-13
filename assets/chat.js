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
    ws.onopen = function() {
      if(userIdExists()) {

          ws.send(JSON.stringify({type: "reconnect", user_id: user.id}));
      } else {

          ws.send(JSON.stringify({type: "new_connection"}));
      }
      console.log('Connected');
    };
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
    } else if(jsonObj.type == "name"){

        user.name = jsonObj.user_name;
    } else if(jsonObj.type == "new_user"){

        appendAdminMessage(jsonObj);
    } else {

        console.log("Error! Receive unexpected message" + jsonObj);
    }
}

function processUserId(jsonObj)
{
    user.id = jsonObj.user_id
}

function appendMessage(messageData)
{
    var myDiv = document.createElement("div")
    myDiv.innerHTML = messageData.name + ": " + messageData.message_text + "<br/>";

    $('#msgs').append(myDiv);
}
function appendAdminMessage(messageData)
{
    var myDiv = document.createElement("div")
    myDiv.innerHTML = "Admin: " + messageData.user_name + " has joined the room.<br/>";

    $('#msgs').append(myDiv);
}

function registerEvents()
{
    $('#set-name').click(function(evt){
        var name = $('#name').val();
        user.name = name;
        $.cookie('user_id', user.id);
        ws.send(JSON.stringify({ type: "new_name", user_name: name, user_id: user.id }));
        ws.send(JSON.stringify({ type: "enter_room", user_id: user.id }));
        $('#name-setting').hide();
        $('#chat').show();
    });

    $('#send').click(function(evt){
        var message = $('#message').val();
        send(message);
    });
}

function userIdExists()
{
    if($.cookie('user_id')){

        return true;
    } else {

        return false;
    }

}

$( document ).ready(function() {

    open();

    if(userIdExists()) {

        $('#name-setting').hide();
        var user_id = $.cookie('user_id');
        user.id = user_id;
    } else {

        $('#chat').hide();
    }
    registerEvents();

});
