defmodule TerminationHandler do
  def handle(reason, pid) when reason == { :error, :closed } do
    PubSub.unsubscribe(pid)
  end
end
