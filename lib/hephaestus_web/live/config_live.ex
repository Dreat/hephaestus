defmodule HephaestusWeb.ConfigLive do
  use HephaestusWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:config, [])
      |> assign(:config_meta, [])
      |> assign(:config_file, [])
      |> allow_upload(:config_file,
        accept: ~w(.json)
      )

    {:ok, assign(socket, :config, [])}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("add_section", params, socket) do
    IO.inspect params
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("upload", _params, socket) do
    case uploaded_entries(socket, :config_file) do
    {[_|_] = entries, []} ->
      uploaded_files = for entry <- entries do
        consume_uploaded_entry(socket, entry, fn %{path: path} ->
          {:ok, content} = File.read(path)
          {:ok, c} = Jason.decode(content, keys: :atoms)
          c1 = Hephaestus.Config.get_metadata(c)
          {:ok, {c, c1}}
        end)
      end
      [{c, c1}] = uploaded_files
      socket =
        socket
        |> assign(:config, c)
        |> assign(:config_meta, c1)
      {:noreply, socket}

    _ ->
      {:noreply, socket}
    end
  end

end
