defmodule Pocketbase do
  @moduledoc """
  This struct represents client information for PocketBase. It is
  passed to most functions throughout this package.
  """

  defstruct base_url: "http://localhost:8090"

  @doc """
  Initialize a new client. The only option currently is `:base_url`.
  It defaults to "http://localhost:8090".
  """
  def new(opts) do
    struct!(__MODULE__, opts)
  end
end
