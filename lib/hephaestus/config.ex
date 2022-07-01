defmodule Hephaestus.Config do
  # this will parse config into format that will make possible to 
  # create new UI components easily
  # It does assume "type" as required, but could be configurable
  def get_metadata(config) when is_list(config) do
    config
    |> Enum.map(fn x -> %{type: x.type, fields: Map.keys(x)} end)
    |> Enum.uniq()
  end

  def get_metadata(_), do: {:error, :wrong_input}
end
