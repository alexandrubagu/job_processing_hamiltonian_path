defmodule Web.FallbackController do
  use Phoenix.Controller

  def call(conn, {:error, :circular_dependency_detected}) do
    conn
    |> put_status(422)
    |> json(%{errors: %{tasks: "circular dependency detected"}})
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    errors =
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)

    conn
    |> put_status(422)
    |> json(%{errors: errors})
  end
end
