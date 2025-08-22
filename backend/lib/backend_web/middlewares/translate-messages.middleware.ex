defmodule Backend.TranslateMessages do
  def as_error_array(%Ecto.Changeset{} = changeset) do
    errors = changeset.errors |> Enum.map(fn {field, {message, opts}} ->
      %{
        field: field,
        error: translate_message(message, opts)
      }
    end)
    %{errors: errors}
  end

  def as_single_error(message) when is_binary(message), do: %{error: message}
  def as_single_success(message) when is_binary(message), do: %{success: message}

  defp translate_message(msg, opts) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
