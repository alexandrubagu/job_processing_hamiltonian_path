defmodule Web.JobControllerTest do
  use Web.ConnCase

  describe "create/2" do
    @valid_params %{
      "tasks" => [
        %{"command" => "echo", "name" => "task-1"},
        %{"command" => "cat", "name" => "task-2", "requires" => ["task-3"]},
        %{"command" => "tar", "name" => "task-3", "requires" => ["task-1"]}
      ]
    }

    @invalid_params %{
      "tasks" => [
        %{"name" => "task-1"},
        %{"command" => "tar"}
      ]
    }

    test "returns a job containing tasks in the correct execution order when passing valid params",
         %{conn: conn} do
      assert %{"tasks" => tasks} =
               conn
               |> post(Routes.job_path(conn, :create), @valid_params)
               |> json_response(201)

      assert [
               %{"command" => "echo", "name" => "task-1", "requires" => []},
               %{"command" => "tar", "name" => "task-3", "requires" => ["task-1"]},
               %{"command" => "cat", "name" => "task-2", "requires" => ["task-3"]}
             ] == tasks
    end

    test "returns an error when passing invalid job params", %{conn: conn} do
      assert %{"errors" => %{"tasks" => tasks_errors}} =
               conn
               |> post(Routes.job_path(conn, :create), @invalid_params)
               |> json_response(422)

      assert %{"name" => ["can't be blank"]} in tasks_errors
      assert %{"command" => ["can't be blank"]} in tasks_errors
    end

    test "returns an error when detecting circular dependency", %{conn: conn} do
      params = %{
        "tasks" => [
          %{"command" => "echo", "name" => "task-1", "requires" => ["task-2"]},
          %{"command" => "cat", "name" => "task-2", "requires" => ["task-3"]},
          %{"command" => "tar", "name" => "task-3", "requires" => ["task-1"]}
        ]
      }

      assert %{"errors" => %{"tasks" => "circular dependency detected"}} =
               conn
               |> post(Routes.job_path(conn, :create), params)
               |> json_response(422)
    end
  end
end
