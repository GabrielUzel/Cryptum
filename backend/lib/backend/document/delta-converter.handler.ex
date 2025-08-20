defmodule Backend.DeltaConverter do
  alias TextDelta

  def quill_to_text_delta(%{"ops" => ops}) when is_list(ops) do
    ops =
      Enum.map(ops, fn op ->
        for {k, v} <- op, into: %{} do
          {String.to_atom(k), v}
        end
      end)

    %TextDelta{ops: ops}
  end

  def quill_to_text_delta(_), do: raise(ArgumentError, "Delta inválido")

  def text_delta_to_quill(%TextDelta{ops: ops}) do
    %{"ops" =>
      Enum.map(ops, fn op ->
        for {k, v} <- op, into: %{} do
          {Atom.to_string(k), v}
        end
      end)}
  end
end
