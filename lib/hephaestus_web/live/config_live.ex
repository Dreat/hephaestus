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

  @impl Phoenix.LiveView
  def handle_event("mock_validate", _params, socket) do
    {:noreply, socket}
  end

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
    config_meta = socket.assigns.config_meta
    new_config = Config.add_section(config_meta, type)

    c =
      (socket.assigns.config ++ [new_config])
      |> Enum.sort(fn %{id: id1}, %{id: id2} -> id1 > id2 end)

    {:noreply, assign(socket, :config, c)}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("edit_config", %{"config_form" => %{"config_id" => id} = params}, socket) do
    params =
      Map.drop(params, ["config_id"]) |> Map.new(fn {k, v} -> {String.to_existing_atom(k), v} end)

    config = socket.assigns.config
    c = Enum.find(config, fn %{id: i} -> i == id end)
    c1 = Map.merge(c, params)

    new_config =
      config
      |> Enum.reject(fn x -> x.id == id end)
      |> Enum.concat([c1])
      |> Enum.sort(fn %{id: id1}, %{id: id2} -> id1 > id2 end)

    {:noreply, assign(socket, :config, new_config)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    config = socket.assigns.config

    c =
      Enum.reject(config, fn x -> x.id == id end)
      |> Enum.sort(fn %{id: id1}, %{id: id2} -> id1 > id2 end)

    {:noreply, assign(socket, :config, c)}
  end

  @impl Phoenix.LiveView
  def handle_event("upload", _params, socket) do
    case uploaded_entries(socket, :config_file) do
      {[_ | _] = entries, []} ->
        uploaded_files =
          for entry <- entries do
            consume_uploaded_entry(socket, entry, fn %{path: path} ->
              {:ok, content} = File.read(path)
              {:ok, c} = Jason.decode(content, keys: :atoms)
              c1 = Hephaestus.Config.get_metadata(c)

              c =
                Enum.map(c, fn x -> Map.put(x, :id, Ecto.UUID.generate()) end)
                |> Enum.sort(fn %{id: id1}, %{id: id2} -> id1 > id2 end)

              {:ok, {c, c1}}
            end)
          end

        [{c, c1}] = uploaded_files

        socket =
          socket
          |> assign(:config, c)
          |> assign(:config_meta, c1)
          |> assign(:config_json, "")

        {:noreply, socket}

      _ ->
        {:noreply, socket}
    end
  end
end
