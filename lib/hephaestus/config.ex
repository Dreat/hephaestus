defmodule Hephaestus.Config do
  # this will parse config into format that will make possible to 
  # create new UI components easily
  # It does assume "type" as required, but could be configurable
  def get_metadata(config) when is_list(config) do
    config
    |> Enum.map(fn x ->
      %{
        type: x.type,
        fields: Map.keys(x) |> Enum.reject(fn x -> x == :type end)
      }
    end)
    |> Enum.uniq()
  end

  def get_metadata(_), do: {:error, :wrong_input}

  def create_config(config),
    do:
      config
      |> Enum.map(fn x -> Map.put(x, :id, Ecto.UUID.generate()) end)
      |> Enum.sort(fn %{id: id1}, %{id: id2} -> id1 > id2 end)

  def add_section(config, config_meta, type) do
    %{type: _, fields: fields} = Enum.find(config_meta, fn %{type: t, fields: _} -> t == type end)

    c =
      fields
      |> Map.new(fn x -> {x, nil} end)
      |> Map.put(:id, Ecto.UUID.generate())
      |> Map.put(:type, type)

    (config ++ [c])
    |> Enum.sort(fn %{id: id1}, %{id: id2} -> id1 > id2 end)
  end

  def update_config(config, id, params) do
    params = Map.new(params, fn {k, v} -> {String.to_existing_atom(k), v} end)
    c = Enum.find(config, fn %{id: i} -> i == id end)
    c1 = Map.merge(c, params)

    config
    |> Enum.reject(fn x -> x.id == id end)
    |> Enum.concat([c1])
    |> Enum.sort(fn %{id: id1}, %{id: id2} -> id1 > id2 end)
  end

  def delete_section(config, id) do
    config
    |> Enum.reject(fn x -> x.id == id end)
    |> Enum.sort(fn %{id: id1}, %{id: id2} -> id1 > id2 end)
  end
end
