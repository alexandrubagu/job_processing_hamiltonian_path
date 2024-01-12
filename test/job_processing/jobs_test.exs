defmodule JobProcessing.JobsTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias JobProcessing.Jobs
  alias JobProcessing.Jobs.Job

  describe "run/1" do
    @valid_params %{
      "tasks" => [
        %{"command" => "echo", "name" => "task-1"},
        %{"command" => "cat", "name" => "task-2", "requires" => ["task-3"]},
        %{"command" => "tar", "name" => "task-3", "requires" => ["task-1"]}
      ]
    }

    test "returns a job when passing valid params" do
      assert {:ok,
              %Job{
                tasks: [
                  %Job.Task{name: "task-1", command: "echo", requires: []},
                  %Job.Task{name: "task-2", command: "cat", requires: ["task-3"]},
                  %Job.Task{name: "task-3", command: "tar", requires: ["task-1"]}
                ]
              }} = Jobs.create_job_definition(@valid_params)
    end

    test "returns an error when tasks are missing" do
      assert {:error, %Ecto.Changeset{} = changeset} = Jobs.create_job_definition(%{})
      assert ["can't be blank"] = errors_on(changeset)[:tasks]
    end

    test "returns an error when command is missing" do
      assert {:error, %Ecto.Changeset{} = changeset} =
               Jobs.create_job_definition(%{
                 "tasks" => [
                   %{"name" => "task-1"}
                 ]
               })

      assert %{command: ["can't be blank"]} in errors_on(changeset)[:tasks]
    end

    test "returns an error when name is missing" do
      assert {:error, %Ecto.Changeset{} = changeset} =
               Jobs.create_job_definition(%{
                 "tasks" => [
                   %{"command" => "tar"}
                 ]
               })

      assert %{name: ["can't be blank"]} in errors_on(changeset)[:tasks]
    end

    test "returns and error when passing invalid requires" do
      assert {:error, %Ecto.Changeset{} = changeset} =
               Jobs.create_job_definition(%{
                 "tasks" => [
                   %{"name" => "task-1", "command" => "tar", "requires" => [1]}
                 ]
               })

      assert %{requires: ["is invalid"]} in errors_on(changeset)[:tasks]
    end
  end

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", "#{inspect(value)}")
      end)
    end)
  end
end
