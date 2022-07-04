defmodule HephaestusWeb.ConfigLive do
  use HephaestusWeb, :live_view

  alias Hephaestus.Config

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:config, [])
      |> assign(:config_meta, [])
      |> assign(:config_file, [])
      |> assign(:config_json, "")
      |> allow_upload(:config_file,
        accept: ~w(.json)
      )

    {:ok, assign(socket, :config, [])}
  end

  # this one is for all forms that require validation
  # but there's nothing to validate
  @impl Phoenix.LiveView
  def handle_event("mock_validate", _params, socket) do
    {:noreply, socket}
  end

  # didn't want to put json parsing in template, so that's here
  @impl Phoenix.LiveView
  def handle_event("construct_json", _params, socket) do
    config_json = socket.assigns.config_json

    if config_json == "" do
      {:ok, c} =
        socket.assigns.config
        |> Enum.map(fn x -> Map.drop(x, [:id]) end)
        |> Jason.encode()

      {:noreply, assign(socket, :config_json, c)}
    else
      {:noreply, socket}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("add_section", %{"type" => type}, socket) do
    config = socket.assigns.config
    config_meta = socket.assigns.config_meta
    new_config = Config.add_section(config, config_meta, type)

    {:noreply, assign(socket, :config, new_config)}
  end

  @impl Phoenix.LiveView
  def handle_event("edit_config", %{"config_form" => %{"config_id" => id} = params}, socket) do
    config = socket.assigns.config
    params = Map.drop(params, ["config_id"])
    new_config = Config.update_config(config, id, params)

    {:noreply, assign(socket, :config, new_config)}
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    config = socket.assigns.config
    new_config = Config.delete_section(config, id)

    {:noreply, assign(socket, :config, new_config)}
  end

  @impl Phoenix.LiveView
  def handle_event("upload", _params, socket) do
    case uploaded_entries(socket, :config_file) do
      {[_ | _] = entries, []} ->
        uploaded_files =
          for entry <- entries do
            consume_uploaded_entry(socket, entry, fn %{path: path} ->
              {:ok, content} = File.read(path)
              {:ok, decoded_config} = Jason.decode(content, keys: :atoms)
              config = Config.create_config(decoded_config)
              config_metadata = Config.get_metadata(decoded_config)

              {:ok, {config, config_metadata}}
            end)
          end

        [{config, config_metadata}] = uploaded_files

        socket =
          socket
          |> assign(:config, config)
          |> assign(:config_meta, config_metadata)
          |> assign(:config_json, "")

        {:noreply, socket}

      _ ->
        {:noreply, socket}
    end
  end
end
