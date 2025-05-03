defmodule TranslateErrors do
  def translate_errors(%Ecto.Changeset{} = changeset) do
    errors = changeset.errors |> Enum.map(fn {field, {message, opts}} ->
      %{
        field: field,
        message: translate_message(message, opts),
      }
    end)

    %{errors: errors}
  end

  defp translate_message(msg, opts) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
