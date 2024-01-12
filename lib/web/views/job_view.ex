defmodule Web.JobView do
  @moduledoc false
  use Web, :view

  def render("job.json", %{job: %{tasks: tasks}}) do
    %{tasks: render_many(tasks, Web.TaskView, "task.json", as: :task)}
  end
end
