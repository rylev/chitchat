defmodule ChitChat.ChatHandler do
  def init(_transport, _req, []) do
    # Upgrade request to a websocket
    Logger.log "Recevied websocket request. Upgrading..."
    { :upgrade, :protocol, :cowboy_websocket }
  end

  # We could also have a normal http handler here (i.e. handle/2) , but since we
  # always upgrade the request to a websocket, we have no need for handler

  def websocket_init(_transport, req, _opts) do
    Logger.log "Initializing websocket connection"

    publish_connection
    { :ok, req, :undefined_state }
  end

  def websocket_handle({ :text, message }, req, state) do
    process_message(message)
    { :ok, req, :undefined_state }
  end

  def websocket_info({ :message, message }, req, state) do
    { :reply, { :text, message }, req, state }
  end

  def websocket_terminate(_reason, _req, _state), do: :ok

  def process_message(message) do
    MessageProcessor.process message
  end

  def publish_connection do
    message = [info: [message: "connected", data: [user_id: "123"]]]
    PubSub.publish(message, self)
  end
end
