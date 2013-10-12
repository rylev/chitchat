defmodule ChitChat.RoomHandler do
  def init(_transport, req, []) do
    Logger.log "Fetching Room assets"
    { :ok, req, :undefined_state }
  end

  def handle(req, state) do
    { :ok, response } = :cowboy_req.reply(200, [], AssetManager.fetch("chat.html"), req)
    { :ok, response, state }
  end

  def terminate(_reason, _req, _state), do: :ok
end
