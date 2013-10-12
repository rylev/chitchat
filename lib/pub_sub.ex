defmodule PubSub do
  def init do
    Logger.log("Initializing the pub sub pool")
    pid = spawn_link(fn -> spawn_pub_sub_pool([]) end)
    :erlang.register(:pubsub, pid)
  end

  def subscribe(new_pid) do
    Logger.log("Subscribing #{inspect new_pid}")
    :pubsub <- { :add_pid, new_pid }
  end

  def publish(message) do
    :pubsub <- { :pub, message }
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
      { :add_pid, pid } ->
        spawn_pub_sub_pool([pid|pids])
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
end
