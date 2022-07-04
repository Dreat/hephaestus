defmodule Hephaestus.ConfigTest do
  use Hephaestus.DataCase, async: true

  alias Hephaestus.Config

  describe "config handling" do
    setup do
      {:ok,
       config: [
         %{
           section: "general",
           name: "population",
           type: "range",
           display: "Population",
           min: 0,
           max: 999_999_999,
           value_type: "int"
         },
         %{
           section: "general",
           name: "state",
           type: "select",
           display: "State",
           values: [
             "Alabama",
             "Alaska",
             "California",
             "Colorado",
             "Wyoming"
           ]
         },
         %{
           section: "geographical",
           name: "is_coastal",
           type: "checkbox",
           display: "Is On A Coast"
         },
         %{
           section: "geographical",
           name: "land_size",
           type: "range",
           display: "Land Size",
           min: 0,
           max: 999_999_999,
           value_type: "int"
         }
       ]}
    end

    test "extracts fields and types using get_metadata/1", %{config: config} do
      result = Config.get_metadata(config)

      assert [
               %{
                 type: "range",
                 fields: [:display, :max, :min, :name, :section, :value_type]
               },
               %{type: "select", fields: [:display, :name, :section, :values]},
               %{type: "checkbox", fields: [:display, :name, :section]}
             ] = result
    end

    test "create_config/1 adds random ids to sections", %{config: config} do
      result = Config.create_config(config)

      assert Enum.all?(result, fn x -> x.id != nil end)
    end

    test "add_section/3 adds new section according to the meta", %{config: config} do
      meta = Config.get_metadata(config)
      config = Config.create_config(config)

      assert Enum.count(config, fn x -> x.type == "range" end) == 2

      new_config = Config.add_section(config, meta, "range")

      assert Enum.count(new_config, fn x -> x.type == "range" end) == 3
    end

    test "delete_section/2 removes section by given id", %{config: config} do
      config = Config.create_config(config)
      %{id: id} = Enum.at(config, 0)

      new_config = Config.delete_section(config, id)

      assert Enum.all?(new_config, fn x -> x.id != id end)
    end

    test "update_config/3 updates section specified by id", %{config: config} do
      new_display = "Some test display"
      config = Config.create_config(config)
      %{id: id} = Enum.at(config, 0)

      refute Enum.find(config, fn x -> x.display == new_display end)

      new_config = Config.update_config(config, id, %{"display" => new_display})

      assert Enum.find(new_config, fn x -> x.display == new_display end)
    end
  end
end
