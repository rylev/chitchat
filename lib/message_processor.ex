# {
#   "type" : "chat_message"
#   "message_text" : "This is a chat message"
#   "user_id" : "123"
# }
defmodule JSONProcessor do
  def process(json) do
     decode(json) |> do_process
  end

  defp do_process(json) do
    case json["type"] do
      "connected" ->
        id = json["user_id"]
        name = json["name"]
        new_user_broadcast = [type: "new_user", name: name]
        PubSub.publish(new_user_broadcast)
        User.subscribe(id)
      "chat_message" ->
        chat_message = json["message_text"]
        name = json["user_name"]
        PubSub.publish([type: "message", message_text: chat_message, name: name])
    end
  end

  defp decode(message) do
    { :ok, message } = JSON.decode(message)
    message
  end
end
