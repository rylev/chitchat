defmodule JSONProcessor do
  def process(json) do
     decode(json) |> do_process
  end

  defp do_process(json) do
    case json["type"] do
      "new_connection" ->
        Logger.log("Handling new connection")
        Users.register_new_user
      "reconnect" ->
        Logger.log("Handling reconnect")
        json["user_id"] |> Users.find_by_id  |> Users.reconnect_user
      "new_name" ->
        Logger.log("Handling new name")
        user = json["user_id"] |> Users.find_by_id
        json["user_name"] |> user.name |> Users.update_user
      "enter_room" ->
        Logger.log("Handling entering room")
        user = json["user_id"] |> Users.find_by_id
        Users.subscribe(user)
        [type: "new_user", user_name: user.name] |> PubSub.publish
      "chat_message" ->
        Logger.log("Handling chat message")
        chat_message = json["message_text"]
        name = json["user_name"]
        PubSub.publish([type: "message", message_text: chat_message, name: name])
      _ ->
        Logger.log "Unknow message '#{inspect json}' received from client"
    end
  end

  defp decode(message) do
    { :ok, message } = JSON.decode(message)
    message
  end
end
