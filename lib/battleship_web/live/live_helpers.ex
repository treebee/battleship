defmodule BattleshipWeb.LiveHelpers do
  use Phoenix.HTML

  def render_error(_, _, nil), do: nil

  def render_error(form, field, error) do
    content_tag(:p, error,
      class: "text-red-400",
      phx_feedback_for: input_id(form, field)
    )
  end
end
