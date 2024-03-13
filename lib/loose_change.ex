defmodule LooseChange do
  @moduledoc """
  This struct represents client information for PocketBase. It is
  passed to most functions throughout this package.
  """

  defstruct [:conn, base_path: ""]

  @doc """
  Initialize a new client.
  """
  def new(base_url) do
    with {:ok, base_url} <- URI.new(base_url),
         {:ok, conn} <- Mint.HTTP.connect(base_url.scheme, base_url.host, base_url.port) do
      {:ok, %__MODULE__{conn: conn, base_path: base_url.path}}
    else
      {:error, err} -> {:error, err}
    end
  end
end
