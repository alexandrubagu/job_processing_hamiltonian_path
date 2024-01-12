defmodule JobProcessing.Jobs do
  @moduledoc false

  alias JobProcessing.Jobs.Job

  @doc """
  Used to validate the job params and create a new job struct.
  """
  @spec create_job_definition(map()) :: {:ok, Job.t()} | {:error, Ecto.Changeset.t()}
  def create_job_definition(params), do: Job.changeset(params)
end
