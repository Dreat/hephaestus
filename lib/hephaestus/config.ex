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

  def add_section(config_meta, type) do
    %{type: _, fields: fields} = Enum.find(config_meta, fn %{type: t, fields: _} -> t == type end)

    fields
    |> Map.new(fn x -> {x, nil} end)
    |> Map.put(:id, Ecto.UUID.generate())
    |> Map.put(:type, type)
  end

  def update_config(config, []), do: config

  def update_config(config, [line | rest]) do
    [l1, l2] = String.split(line, ":")
    a = String.to_existing_atom(l1)
    l2 = String.trim(l2)
    config = Map.put(config, a, l2)
    update_config(config, rest)
  end
end
