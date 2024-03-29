defmodule Web.Router do
  use Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Web do
    pipe_through :api

    post "/jobs", JobController, :create
  end
end
