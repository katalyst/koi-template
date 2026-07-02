# frozen_string_literal: true

threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

if ENV["PUMA_SSL"].present?
  ssl_bind(
    "[::]",
    "4443",
    key:  File.expand_path("~/.ssl/docker.key"),
    cert: File.expand_path("~/.ssl/docker.crt"),
  )
else
  # Allow puma to be restarted by `bin/rails restart` command.
  plugin :tmp_restart

  # Specifies the `port` that Puma will listen on to receive requests.
  port ENV.fetch("PORT", 3000)
end

# Run Solid Queue in async mode inside Puma for single-server deployments
if ENV["SOLID_QUEUE_IN_PUMA"]
  plugin :solid_queue
  solid_queue_mode :async if ENV.fetch("WEB_CONCURRENCY", 0).to_i.zero?
end

# Specify the PID file. Defaults to tmp/pids/server.pid in development.
# In other environments, only set the PID file if requested.
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
