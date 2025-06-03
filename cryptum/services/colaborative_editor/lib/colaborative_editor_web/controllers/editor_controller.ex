defmodule ColaborativeEditorWeb.EditorController do
  use ColaborativeEditorWeb, :controller
  alias HTTPoison

  # @file_service_url "http://localhost:4005/api"

  def edit_file(conn, %{"filename" => filename}) do
    if String.ends_with?(filename, ".tex") do
      path = Path.expand("temp/latex/#{filename}")

      case File.read(path) do
        {:ok, content} ->
          render(conn, "editor.html", filename: filename, content: content)

        {:error, _reason} ->
          conn
          |> put_status(:not_found)
          |> json(%{ message: "Arquivo não encontrado" })
      end
    else
      conn
      |> put_status(:bad_request)
      |> json(%{ message: "Extensão não suportada" })
    end
  end

  # def edit_file(conn, %{"file_id" => file_id}) do
  #   url = "#{@file_service_url}/#{file_id}"

  #   case HTTPoison.get(url, [], recv_timeout: 5000) do
  #     {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
  #       {:ok, file_info} = Jason.decode(body)

  #       if allowed_extension?(file_info["name"]) do
  #         render(conn, "edit.html", filename: file_info["name"], file_url: file_info["path"])
  #       else
  #         render(conn, "unsupported_extension.html", filename: file_info["name"])
  #       end
  #     {:ok, %HTTPoison.Response{status_code: 404}} ->
  #       conn
  #       |> put_status(:not_found)
  #       |> json(%{ message: "Arquivo não encontrado" })

  #       {:error, _reason} ->
  #       conn
  #       |> put_status(:bad_gateway)
  #       |> json(%{ message: to_string(reason) })
  #   end
  # end

  # defp allowed_extension?(filename) do
  #   Path.extname(filename) == ".tex"
  # end
end
