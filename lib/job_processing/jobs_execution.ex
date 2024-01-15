defmodule JobProcessing.JobsExecution do
  @moduledoc """
  TaskExecution is responsible for returning execution tasks in correct order.
  """

  alias JobProcessing.Jobs.Job.Task
  alias JobProcessing.Jobs.Job

  defstruct [:tasks_lookup, execution_paths: [], current_path: [], error: nil]

  @doc """
  Generates all possible execution paths for a given job and returns the one containing all task names.
  """
  @spec new(Job.t()) :: {:ok, Job.t()} | {:error, :circular_dependency_detected} | {:error, :no_path_found}
  def new(%Job{} = job) do
    %__MODULE__{tasks_lookup: build_tasks_lookup(job.tasks)}
    |> generate_execution_paths()
    |> select_execution()
  end

  defp generate_execution_paths(context) do
    context.tasks_lookup
    |> Map.keys()
    |> Enum.reduce(context, &build_path(&2, get_task(&2, &1)))
  end

  defp build_path(context, %Task{name: name, requires: []}) do
    end_path = [name | context.current_path]

    context
    |> add_path(end_path)
    |> reset_current_path()
  end

  defp build_path(context, %Task{name: name, requires: requires}) do
    case circular_dependency?(context, name) do
      true ->
        set_error(context, :circular_dependency_detected)

      false ->
        new_path = [name | context.current_path]
        context = set_current_path(context, new_path)
        Enum.reduce(requires, context, &build_path(&2, get_task(&2, &1)))
    end
  end

  defp select_execution(%{error: nil} = context) do
    sorted_task_names = context.tasks_lookup |> Map.keys() |> Enum.sort()
    path = Enum.find(context.execution_paths, &(Enum.sort(&1) == sorted_task_names))

    if path,
      do: {:ok, %Job{tasks: Enum.map(path, &get_task(context, &1))}},
      else: {:error, :no_path_found}
  end

  defp select_execution(%{error: error}), do: {:error, error}

  defp build_tasks_lookup(tasks), do: Map.new(tasks, &{&1.name, &1})
  defp get_task(context, name), do: Map.get(context.tasks_lookup, name)
  defp add_path(context, path), do: %{context | execution_paths: [path | context.execution_paths]}
  defp reset_current_path(context), do: %{context | current_path: []}
  defp set_current_path(context, path), do: %{context | current_path: path}
  defp set_error(context, error), do: %{context | error: error}
  defp circular_dependency?(context, name), do: name in context.current_path
end
