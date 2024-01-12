import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :job_processing, Web.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "HmwEe8saKi9aYota2wwehY9tERtWEqPmQxSAqrLGma2OZMhoVXMY2C3hnS2z6WoV",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
