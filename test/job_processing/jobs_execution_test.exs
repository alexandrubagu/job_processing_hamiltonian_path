defmodule JobProcessing.JobsExecutionTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias JobProcessing.Jobs.Job
  alias JobProcessing.JobsExecution

  describe "new/1" do
    @valid_job %Job{
      tasks: [
        %Job.Task{name: "task-1", command: "touch /tmp/file1", requires: []},
        %Job.Task{name: "task-2", command: "cat /tmp/file1", requires: ["task-3"]},
        %Job.Task{name: "task-3", command: "echo 'X' > /tmp/file1", requires: ["task-1"]},
        %Job.Task{name: "task-4", command: "rm /tmp/file1", requires: ["task-2", "task-3"]}
      ]
    }

    test "orders the job tasks" do
      assert {:ok,
              %Job{
                tasks: [
                  %Job.Task{name: "task-1", command: "touch /tmp/file1", requires: []},
                  %Job.Task{
                    name: "task-3",
                    command: "echo 'X' > /tmp/file1",
                    requires: ["task-1"]
                  },
                  %Job.Task{name: "task-2", command: "cat /tmp/file1", requires: ["task-3"]},
                  %Job.Task{
                    name: "task-4",
                    command: "rm /tmp/file1",
                    requires: ["task-2", "task-3"]
                  }
                ]
              }} = JobsExecution.new(@valid_job)
    end

    test "returns an error when the job has a circular dependency" do
      job = %Job{
        tasks: [
          %Job.Task{name: "task-1", command: "touch /tmp/file1", requires: ["task-2"]},
          %Job.Task{name: "task-2", command: "cat /tmp/file1", requires: ["task-3"]},
          %Job.Task{name: "task-3", command: "cat /tmp/file1", requires: ["task-1"]}
        ]
      }

      assert {:error, :circular_dependency_detected} = JobsExecution.new(job)
    end

    test "returns an error when no path is found between all tasks" do
      job = %Job{
        tasks: [
          %Job.Task{name: "task-1", command: "touch /tmp/file1", requires: ["task-2"]},
          %Job.Task{name: "task-2", command: "cat /tmp/file1", requires: []},
          %Job.Task{name: "task-3", command: "cat /tmp/file1", requires: []}
        ]
      }

      assert {:error, :no_path_found} = JobsExecution.new(job)
    end
  end
end
