defmodule Users do
  defrecord User, pid: nil, id: nil, name: nil
  @id_length 15

  def init do
    pid = spawn_link(fn -> users_loop([]) end)
    :erlang.register(:users, pid)
  end

  def find_by_id(id) do
    find_by(:id, id)
  end

  def find_by_pid(pid) do
    find_by(:pid, pid)
  end

  def register_new_user do
    new_user = User.new(pid: self, id: random_id)
    :users <- { :new_user, new_user }

    connected_message = [type: "connected", user_id: new_user.id ]
    PubSub.publish(connected_message, new_user.pid)
  end

  def reconnect_user(user) do
    subscribe(user)
    PubSub.publish([type: "name", user_name: user.name], self)
  end

  def subscribe(user) do
    (user = user.pid(self)) |> update_user
    PubSub.subscribe(self)
  end

  def update_user(user) do
    :users <- { :update_user, user }
  end

  defp users_loop(users) do
    receive do
      { :pid, pid, querier_pid } ->
        user = Enum.find users, fn(user) ->  user.pid == pid end
        querier_pid <- { :user, user }
        users_loop(users)
      { :id, id, querier_pid } ->
        user = Enum.find users, fn(user) ->  user.id == id end
        querier_pid <- { :user, user }
        users_loop(users)
      { :new_user, user } ->
        users_loop([user|users])
      { :update_user, user } ->
        other_users = Enum.reject users, fn(u) -> u.id == user.id end
        users_loop([user|other_users])
      { :die } ->
        :ok
    end
  end

  defp random_id do
    @id_length |> :crypto.strong_rand_bytes |> :base64.encode
  end

  defp find_by(attr, value) do
    :users <- { attr, value, self }
    receive do
      { :user, user  } -> user
    end
  end
end
