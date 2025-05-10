defmodule MailerServiceWeb.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.ChannelTest
      import MailerServiceWeb.ChannelCase

      @endpoint MailerServiceWeb.Endpoint
    end
  end

  setup _tags do
    :ok
  end
end
