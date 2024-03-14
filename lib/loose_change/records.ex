defmodule LooseChange.Records do
  @moduledoc """
  This module provides functionality for performing CRUD operations on records.
  """

  @type collection_id() :: String.t()
  @type response() :: {:ok, Req.Response.t()} | {:error, Exception.t()}

  @spec list(LooseChange.t(), collection_id(), keyword()) :: response()
  def list(%LooseChange{} = client, collection, opts \\ []) do
    opts =
      Keyword.validate!(
        opts,
        [:page, :per_page, :sort, :filter, :expand, :fields, :skip_total, :into]
      )

    {opts, query} = Keyword.split(opts, [:into])
    query = query |> normalize_sort()
    query = query |> normalize_list(:expand)
    query = query |> normalize_list(:fields)

    case client.req
         |> Req.get(
           Keyword.merge(opts,
             url: "/api/collections/:collection/records",
             path_params: [collection: collection],
             params: query
           )
         ) do
      {:ok, rsp} -> normalize_response(rsp)
      {:error, err} -> {:error, err}
    end
  end

  @spec auth_with_password(LooseChange.t(), collection_id(), String.t(), String.t(), keyword()) ::
          response()
  def auth_with_password(%LooseChange{} = client, collection, identity, password, opts \\ []) do
    query = Keyword.validate!(opts, [:expand, :fields])
    query = query |> normalize_list(:expand)
    query = query |> normalize_list(:fields)

    with {:ok, body} <- %{identity: identity, password: password} |> Jason.encode(),
         {:ok, rsp} <-
           client.req
           |> Req.post(
             url: "/api/collections/:collection/auth-with-password",
             path_params: [collection: collection],
             body: body,
             params: query
           ) do
      normalize_response(rsp)
    else
      {:error, err} -> {:error, err}
    end
  end

  @spec normalize_sort(keyword()) :: keyword()
  defp normalize_sort(opts) do
    Keyword.replace_lazy(opts, :sort, fn
      sort when is_list(sort) ->
        sort
        |> Enum.map(fn
          {:asc, id} -> "+#{id}"
          {:desc, id} -> "-#{id}"
          id -> "#{id}"
        end)
        |> Enum.join(",")

      sort when is_binary(sort) ->
        sort
    end)
  end

  @spec normalize_list(keyword(), atom()) :: keyword()
  defp normalize_list(opts, name) do
    Keyword.replace_lazy(opts, name, fn
      opt when is_list(opt) -> opt |> Enum.join(",")
      opt -> opt
    end)
  end

  @spec normalize_response(Req.Response.t()) :: {:error, LooseChange.ServerError.t()}
  defp normalize_response(%Req.Response{
         status: status,
         body: %{"data" => data, "message" => message}
       })
       when status >= 400 do
    {:error, %LooseChange.ServerError{code: status, data: data, message: message}}
  end

  @spec normalize_response(Req.Response.t()) :: {:ok, Req.Response.t()}
  defp normalize_response(%Req.Response{} = rsp), do: {:ok, rsp}
end
