defmodule MessageProcessor do
  def process(message) do
     decode(message) |> do_process
  end

  def do_process(message) do
    case message["info"]["message"] do
      "connected" ->
        name = message["info"]["data"]["user_name"]
        PubSub.subscribe({ self, name })
      "message" ->
        chat_message = message["info"]["data"]["chat_message"]
        name = message["info"]["data"]["user_name"]
        publish([name: name, chat_message: chat_message])
    end
  end

  def publish(message) do
    PubSub.publish([info: [message: "message", data: message]])
  end

  def decode(message) do
    { :ok, message } = JSON.decode(message)
    message
  end
end
