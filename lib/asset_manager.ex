defmodule AssetManager do
  def fetch(filename) when is_binary(filename) do
    Path.expand("assets/#{filename}") |> File.read!
  end

  def fetch(req) do
    { asset_name, _req } = :cowboy_req.binding(:asset, req)
    fetch(asset_name)
  end
end
