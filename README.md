# About

This is an example of implementation for [Hamiltonian path](https://en.wikipedia.org/wiki/Hamiltonian_path)

> Hamiltonian path (or traceable path) is a path in an undirected or directed graph that visits each vertex exactly once

This implementation uses recursion to generate all possible paths between tasks. At the end a valid path is returned in case all tasks are present in the path.

**_If a circular dependency is detected or no path is found an error is returned._**

## Implementation details

- Incoming requests are validated using Ecto embedded schemas
- If the request is invalid, the server returns a 422 status code using `Web.FallbackController`
- If the request is valid, `JobsExecution` is called. If a circular dependency is detected, the server returns a 422 otherwise it returns a 201 with the the first valid path.

## Start the server

- Install dependencies with `mix deps.get`
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can test the API using curl

```bash
curl 'http://localhost:4000/api/jobs' \
     -X POST \
     -H 'Content-Type: application/json' \
     -d '{"tasks":[{"name":"task-1","command":"touch /tmp/file1"},{"name":"task-2","command":"cat /tmp/file1","requires":["task-3"]},{"name":"task-3","command":"echo Hello > /tmp/file1","requires":["task-1"]},{"name":"task-4","command":"rm /tmp/file1","requires":["task-2","task-3"]}]}'
```

## Run the tests

- Install dependencies with `mix deps.get`
- Run `mix test`
