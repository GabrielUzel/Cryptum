defmodule BackendWeb.CompilerController do
  # TODO: Adaptar esse compilador para receber um arquivo de Azure blob storage
  use BackendWeb, :controller

  def compile(conn, %{"file" => %Plug.Upload{path: temp_path, filename: filename}}) do
    safe_filename = filename
      |> Path.basename()
      |> String.replace(~r/[^a-zA-Z0-9_\-.]/, "")

    if Path.extname(safe_filename) != ".tex" do
      conn
      |> put_resp_content_type("application/json")
      |> json(%{ message: "Only .tex files are permitted" })
    end

    output_dir = Path.join(System.tmp_dir!(), "latex_output_#{:os.system_time(:millisecond)}")
    File.mkdir_p!(output_dir)

    tex_file = Path.join(output_dir, safe_filename)
    File.cp!(temp_path, tex_file)

    case System.cmd("pdflatex", ["-output-directory", output_dir, "-halt-on-error", "--no-shell-escape", tex_file], stderr_to_stdout: true) do
      {_, 0} ->
        pdf_filename = String.replace_suffix(safe_filename, ".tex", ".pdf")
        pdf_path = Path.join(output_dir, pdf_filename)
        log_path = Path.join(output_dir, String.replace_suffix(filename, ".tex", ".log"))

        if File.exists?(pdf_path) do
          pdf_content = File.read!(pdf_path)
          log_content = File.read!(log_path)

          conn
          |> put_resp_content_type("application/json")
          |> send_resp(200, Jason.encode!(%{
            pdf: Base.encode64(pdf_content),
            log: log_content,
            filename: pdf_filename
          }))
        else
          conn
          |> put_resp_content_type("application/json")
          |> json(%{ message: "An error occurred, the PDF was not generated" })
        end

      {error_output, _exit_code} ->
        conn
          |> put_resp_content_type("application/json")
          |> json(%{ message: "Error: \n#{error_output}" })
    end
  end
end
