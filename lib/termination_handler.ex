defmodule TerminationHandler do
  def handle(reason, user) when reason == { :error, :closed } do
    PubSub.unsubscribe(user)
  end
end
