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

    PubSub.subscribe(self)
    PubSub.publish([ info: ], self)
    { :ok, req, :undefined_state }
  end

  def websocket_handle({ :text, message }, req, state) do
    PubSub.publish(message)
    { :ok, req, :undefined_state }
  end

  def websocket_info({ :message, message }, req, state) do
    { :reply, { :text, message }, req, state }
  end

  def websocket_terminate(_reason, _req, _state), do: :ok
end
