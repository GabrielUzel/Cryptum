defmodule BackendWeb.CompilerController do
  use BackendWeb, :controller

  @compile_timeout 30_000
  @max_file_size 10_000_000

  def compile(conn, %{
        "file" => %Plug.Upload{path: temp_path, filename: filename, content_type: content_type}
      }) do
    with :ok <- validate_file_size(temp_path),
         :ok <- validate_content_type(content_type),
         :ok <- validate_extension(filename) do
      compile_tex(conn, temp_path, filename)
    else
      {:error, message} ->
        conn
        |> put_status(400)
        |> put_resp_content_type("application/json")
        |> json(%{message: message})
        |> halt()
    end
  end

  def compile(conn, _params) do
    conn
    |> put_status(400)
    |> put_resp_content_type("application/json")
    |> json(%{message: "No file provided"})
    |> halt()
  end

  defp compile_tex(conn, temp_path, filename) do
    safe_filename = sanitize_filename(filename)
    output_dir = create_output_dir()

    try do
      tex_file = Path.join(output_dir, safe_filename)
      File.cp!(temp_path, tex_file)

      case compile_with_pdflatex(tex_file, output_dir) do
        {:ok, _} ->
          case compile_with_pdflatex(tex_file, output_dir) do
            {:ok, _} ->
              send_success_response(conn, output_dir, safe_filename)

            {:error, error_output} ->
              send_compile_error(conn, error_output)
          end

        {:error, error_output} ->
          send_compile_error(conn, error_output)
      end
    after
      cleanup_output_dir(output_dir)
    end
  end

  defp compile_with_pdflatex(tex_file, output_dir) do
    task =
      Task.async(fn ->
        System.cmd(
          "pdflatex",
          [
            "-output-directory",
            output_dir,
            "-halt-on-error",
            "-interaction=nonstopmode",
            "--no-shell-escape",
            tex_file
          ],
          stderr_to_stdout: true,
          into: []
        )
      end)

    case Task.yield(task, @compile_timeout) || Task.shutdown(task) do
      {:ok, {output, 0}} ->
        {:ok, output}

      {:ok, {output, _exit_code}} ->
        {:error, output}

      nil ->
        {:error, "Compilation timeout after #{@compile_timeout}ms"}

      {:exit, _reason} ->
        {:error, "Compilation process crashed"}
    end
  end

  defp send_success_response(conn, output_dir, safe_filename) do
    pdf_filename = Path.rootname(safe_filename) <> ".pdf"
    pdf_path = Path.join(output_dir, pdf_filename)
    log_filename = Path.rootname(safe_filename) <> ".log"
    log_path = Path.join(output_dir, log_filename)

    if File.exists?(pdf_path) do
      pdf_content = File.read!(pdf_path)
      log_content = if File.exists?(log_path), do: File.read!(log_path), else: ""

      conn
      |> put_resp_content_type("application/json")
      |> json(%{
        pdf: Base.encode64(pdf_content),
        log: log_content,
        filename: pdf_filename
      })
    else
      conn
      |> put_status(500)
      |> put_resp_content_type("application/json")
      |> json(%{message: "PDF was not generated"})
    end
  end

  defp send_compile_error(conn, error_output) do
    conn
    |> put_status(422)
    |> put_resp_content_type("application/json")
    |> json(%{message: "Compilation error", error: error_output})
  end

  defp validate_file_size(temp_path) do
    case File.stat(temp_path) do
      {:ok, %File.Stat{size: size}} when size > @max_file_size ->
        {:error, "File too large. Maximum size is #{@max_file_size} bytes"}

      {:ok, _} ->
        :ok

      {:error, _} ->
        {:error, "Could not read file"}
    end
  end

  defp validate_content_type("application/x-tex"), do: :ok
  defp validate_content_type("text/x-tex"), do: :ok
  defp validate_content_type("application/octet-stream"), do: :ok
  defp validate_content_type(_), do: {:error, "Invalid content type"}

  defp validate_extension(filename) do
    if Path.extname(filename) == ".tex" do
      :ok
    else
      {:error, "Only .tex files are permitted"}
    end
  end

  defp sanitize_filename(filename) do
    filename
    |> Path.basename()
    |> String.replace(~r/[^a-zA-Z0-9_\-.]/, "_")
  end

  defp create_output_dir do
    output_dir = Path.join(System.tmp_dir!(), "latex_#{:os.system_time(:millisecond)}")
    File.mkdir_p!(output_dir)
    output_dir
  end

  defp cleanup_output_dir(output_dir) do
    File.rm_rf!(output_dir)
  rescue
    _ -> :ok
  end
end
