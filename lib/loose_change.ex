defmodule LooseChange do
  @moduledoc """
  This struct represents client information for PocketBase. It is
  passed to most functions throughout this package.
  """

  defstruct [:req]

  @opaque t() :: %__MODULE__{}

  @spec new(Req.url()) :: t()
  @doc """
  Initialize a new client.
  """
  def new(base_url) do
    %__MODULE__{req: Req.new(base_url: base_url)}
  end

  @spec with_auth(t(), Req.Response.t()) :: t()
  def with_auth(%__MODULE__{req: req}, %Req.Response{body: %{"token" => token}}) do
    %__MODULE__{req: req |> Req.merge(headers: %{"authentication" => token})}
  end
end
