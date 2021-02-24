defmodule Battleship.Repo do
  use Ecto.Repo,
    otp_app: :battleship,
    adapter: Ecto.Adapters.Postgres,
    ssl: true

  defoverridable insert: 2

  def insert(changeset, opts) do
    super(changeset, opts)
  rescue
    exception in Postgrex.Error ->
      handle_postgrex_exception(exception, __STACKTRACE__, changeset)
  end

  defp handle_postgrex_exception(
         %{postgres: %{code: :raise_exception, message: message}},
         _,
         _changeset
       ) do
    {:error, message}
  end

  defp handle_postgrex_exception(exception, stacktrace, _) do
    reraise(exception, stacktrace)
  end
end
