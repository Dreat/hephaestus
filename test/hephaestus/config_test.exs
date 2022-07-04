defmodule Hephaestus.ConfigTest do
  use Hephaestus.DataCase, async: true

  alias Hephaestus.Config

  describe "extract metadata from existing config" do
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

    test "extracts fields and types", %{config: config} do
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
  end
end
