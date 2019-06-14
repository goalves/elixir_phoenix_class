defmodule EPClassWeb.ChangesetView do
  use EPClassWeb, :view
  alias Ecto.Changeset

  def render("error.json", changeset = %Changeset{}),
    do: %{errors: changeset |> Changeset.traverse_errors(& &1) |> handle_errors()}

  defp handle_errors(details),
    do: Enum.map(details, fn {field, detail} -> %{"#{field}" => serialize_detail(detail)} end)

  defp serialize_detail(inner_details) when is_list(inner_details) do
    inner_details
    |> Enum.map(&serialize_single_element/1)
    |> List.flatten()
  end

  defp serialize_detail(inner_details),
    do: serialize_single_element(inner_details)

  defp serialize_single_element({msg, opts}) when is_bitstring(msg) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      case value do
        {_key, type} -> serialize_single_element({msg, [type: type]})
        _ -> String.replace(acc, "%{#{key}}", to_string(value))
      end
    end)
  end

  defp serialize_single_element(inner_detail_element), do: handle_errors(inner_detail_element)
end
