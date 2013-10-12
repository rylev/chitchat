defmodule ChitChat.AssetsHandler do
  def init(_transport, req, []) do
    { :ok, req, :undefined_state }
  end

  def handle(req, state) do
    # TODO: make sure to return with correct MIME/TYPE
    { :ok, response } = :cowboy_req.reply(200, [], asset(req), req)
    { :ok, response, state }
  end

  def terminate(_reason, _req, _state),  do: :ok

  defp asset(req) do
    AssetManager.fetch req
  end
end
