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

# Run the Solid Queue supervisor inside Puma for single-server deployments
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

# Specify the PID file. Defaults to tmp/pids/server.pid in development.
# In other environments, only set the PID file if requested.
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]

# When running in cluster mode with preload_app! we need to re-open the logger
# outputs in each worker thread (after fork).
if ENV.fetch("WEB_CONCURRENCY", 0).to_i > 1
  on_worker_boot do
    SemanticLogger.reopen if defined?(SemanticLogger)
  end
end
