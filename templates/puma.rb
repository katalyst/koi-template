#!/usr/bin/env ruby
# frozen_string_literal: true

# update application.rb configuration with Koi defaults
gsub_file("config/puma.rb",
          /^# Specifies.*default is 3000.\nport.*\n/) do
  <<-RUBY
# Allow binding to a socket, nginx will be acting as a reverse proxy.
if ENV["PUMA_BIND"].present?
  bind ENV["PUMA_BIND"]
else
  port ENV.fetch("PORT", 3000)
end
  RUBY
end

append_to_file("config/puma.rb") do
  <<-RUBY
    
# When running in cluster mode with preload_app! we need to re-open the logger
# outputs in each worker thread (after fork).
on_worker_boot do
  SemanticLogger.reopen
end
  RUBY
end
