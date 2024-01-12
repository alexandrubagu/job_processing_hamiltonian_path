defmodule JobProcessing do
  @moduledoc """
  JobProcessing is responsible for creating jobs.
  """

  alias JobProcessing.Jobs
  alias JobProcessing.JobsExecution

  @spec create_job(map()) ::
          {:ok, Jobs.Job.t()}
          | {:error, Ecto.Changeset.t()}
          | {:error, :circular_dependency_detected}
  def create_job(params) do
    with {:ok, job} <- Jobs.create_job_definition(params) do
      JobsExecution.new(job)
    end
  end
end
