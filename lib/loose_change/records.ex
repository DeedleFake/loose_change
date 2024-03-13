defmodule LooseChange.Records do
  @moduledoc """
  This module provides functionality for performing CRUD operations on records.
  """

  def list(%LooseChange{} = client, collection, opts \\ []) do
    opts =
      Keyword.validate!(
        opts,
        [:page, :per_page, :sort, :filter, :expand, :fields, :skip_total, into: nil]
      )

    {into, opts} = opts |> Keyword.pop(:into)
    opts = opts |> normalize_sort()
    opts = opts |> normalize_list(:expand)
    opts = opts |> normalize_list(:fields)

    client.req
    |> Req.get(
      url: "/api/collections/:collection/records",
      path_params: [collection: collection],
      params: opts,
      into: into
    )
  end

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

  defp normalize_list(opts, name) do
    Keyword.replace_lazy(opts, name, fn
      opt when is_list(opt) -> opt |> Enum.join(",")
      opt -> opt
    end)
  end
end
