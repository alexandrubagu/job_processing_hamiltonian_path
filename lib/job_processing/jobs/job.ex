defmodule JobProcessing.Jobs.Job do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key false
  @required_fields ~w(name command)a
  @optional_fields ~w(requires)a

  embedded_schema do
    embeds_many :tasks, Task do
      field :name, :string
      field :command, :string
      field :requires, {:array, :string}, default: []
    end
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [])
    |> cast_embed(:tasks, required: true, with: &task_changeset/2)
    |> apply_action(:insert)
  end

  def task_changeset(task, attrs \\ %{}) do
    task
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
