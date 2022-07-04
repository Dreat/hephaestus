defmodule HephaestusWeb.DownloadController do
  use HephaestusWeb, :controller

  def download(conn, %{"download" => %{"config" => config, "filename" => filename}}) do
    send_download(conn, {:binary, config}, filename: filename)
  end
end
