defmodule ChitChat.HealthCheckHandler do
  # Init is required for every Cowboy handler
  # It takes three arguments:
  #   transport: The Transport/Protocol in use
  #   req: A request object
  #   options: Options defined in the routes
  def init(_transport, req, []) do
    { :ok, req, :undefined_state }
  end

  # Handles the request
  # It takes two arguments:
  #   req: The request object
  #   state: the state defined in the init function
  def handle(req, state) do
    { :ok, response } = :cowboy_req.reply(200, [], "{ up: true }", req)
    { :ok, response, state }
  end

  # Cleans up the handler process
  # It takes three arguments:
  #   reason: The reason for the termination
  #   req: The request object
  #   state: the state defined in the init function
  def terminate(_reason, _req, _state), do: :ok
end
