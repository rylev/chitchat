defmodule Users do
  defrecord User, pid: nil, id: nil, name: nil
  @id_length 15

  def init do
    spawn_link(fn -> users_loop([]) end)
  end

  def find_by_id(id) do
    :users <- { :id, id }
    receive do
      { :user, user  } -> user
    end
  end

  def register_new_user do
    user = User.new(pid: self, id: random_id)
    connected_message = [type: "connected", user_id: user.id ]
    :users <- { :new_user, user }
    PubSub.publish(connected_message, user.pid)
  end

  def subscribe(id) do
    user = find_by_id(id)
    user = user.pid(self)
    update_user(user)
    PubSub.subscribe(user)
  end

  def update_user(user) do
    :users <- { :update_user, user }
  end

  defp users_loop(users) do
    receive do
      { :id, id } ->
        user = Enum.find users, fn(user) ->  user.id == id end
        user.pid <- { :user, user }
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
end
