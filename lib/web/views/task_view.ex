defmodule Web.TaskView do
  @moduledoc false
  use Web, :view

  def render("task.json", %{task: task}) do
    %{
      name: task.name,
      command: task.command,
      requires: task.requires
    }
  end
end
