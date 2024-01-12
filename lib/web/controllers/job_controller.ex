defmodule Web.JobController do
  use Web, :controller

  action_fallback Web.FallbackController

  def hello(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{message: "Hello World!"})
  end

  def create(conn, params) do
    with {:ok, job} <- JobProcessing.create_job(params) do
      conn
      |> put_status(201)
      |> render("job.json", job: job)
    end
  end
end
