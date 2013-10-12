defmodule PubSub do
  defrecord Message, message: nil, data: nil
  def init do
    Logger.log("Initializing the pub sub pool")
    pid = spawn_link(fn -> spawn_pub_sub_pool([]) end)
    :erlang.register(:pubsub, pid)
  end

  def subscribe(user = { _new_pid, name}) do
    Logger.log("Subscribing #{name}")
    :pubsub <- { :add_user, user }
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

  defp spawn_pub_sub_pool(users) do
    pids = ListDict.keys users
    receive do
      { :pub, message } ->
        send_message(pids, message)
        spawn_pub_sub_pool(users)
      { :add_user, user = {_pid, name } } ->
        send_message(pids, json_for([info: [message: "new_user", data: [user_name: name]]]))
        spawn_pub_sub_pool([user|users])
      { :show, pid } ->
        pid <- { :pids, pids }
        spawn_pub_sub_pool(users)
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
