defmodule PubSub do
  def init do
    Logger.log("Initializing the pub sub pool")
    pid = spawn_link(fn -> spawn_pub_sub_pool([]) end)
    :erlang.register(:pubsub, pid)
  end

  def subscribe(pid) do
    Logger.log("Subscribing #{inspect pid}")
    :pubsub <- { :subscribe, pid }
  end
  def unsubscribe(pid) do
    Logger.log("Unsubscribing old process #{inspect pid}")
    :pubsub <- { :unsubscribe, pid }
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
      { :subscribe, pid } ->
        spawn_pub_sub_pool([pid|pids])
      { :unsubscribe, pid } ->
        new_pids = Enum.reject pids, &(&1 == pid)
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
