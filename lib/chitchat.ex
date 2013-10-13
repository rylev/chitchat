defmodule ChitChat do
  use Application.Behaviour

  def start(_type, _args) do
    {:ok, _} = :cowboy.start_http(:http, 100,
                                  [port: 8080],
                                  [env: [dispatch: router]])
    Users.init
    PubSub.init
    ChitChat.Supervisor.start_link
  end

  defp router do
    # Routing takes the following form:
    # { HOST, [{ PATH, "CONTROLLER_MODULE", OPTIONS }]
    :cowboy_router.compile([ { :_ ,  routes } ])
  end

  def routes do
    [
      { "/", ChitChat.RoomHandler, [] },
      { "/chat", ChitChat.ChatHandler, [] },
      { "/health", ChitChat.HealthCheckHandler, [] },
      { "/assets/:asset", ChitChat.AssetsHandler, [] }
    ]
  end
end
