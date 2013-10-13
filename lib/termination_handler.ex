defmodule TerminationHandler do
  def handle(reason, user_id) when reason == { :error, :closed } do
  end
end
