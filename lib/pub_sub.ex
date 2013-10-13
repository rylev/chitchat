defmodule PubSub do
  def init do
    Logger.log("Initializing the pub sub pool")
    pid = spawn_link(fn -> spawn_pub_sub_pool([]) end)
    :erlang.register(:pubsub, pid)
  end

  def subscribe(user) do
    Logger.log("Subscribing #{user.name}")
    :pubsub <- { :subscribe, user }
  end
  def unsubscribe(user) do
    Logger.log("Unsubscribing old process #{inspect user.pid}")
    :pubsub <- { :unsubscribe, user }
  end

  def publish(message) do
    :pubsub <- { :pub, json_for message }
  end

  def publish(message, pids) when is_list(pids) do
    send_message(pids, json_for(message))
  end
  def publish(message, pid) do
    publish(message, [pid])
  end

  def processes do
    :pubsub <- { :show, self }
    receive do
      { :pids, pids } -> pids
    end
  end

  defp spawn_pub_sub_pool(pids) do
    receive do
      { :pub, message } ->
        send_message(pids, message)
        spawn_pub_sub_pool(pids)
      { :subscribe, user } ->
        spawn_pub_sub_pool([user.pid|pids])
      { :unsubscribe, user } ->
        new_pids = Enum.reject pids, fn(pid) -> user.pid == pid end
        spawn_pub_sub_pool(new_pids)
      { :show, pid } ->
        pid <- { :pids, pids }
        spawn_pub_sub_pool(pids)
      :die ->
        :ok
    end
  end

  defp send_message(pids, message) do
    Enum.each pids, fn(pid)-> pid <- { :message, message } end
  end

  def json_for(message) do
    { :ok, json } = JSON.encode(message)
    json
  end
end
