#!/usr/bin/env ruby
# frozen_string_literal: true

# Use rails_semantic_logger to log to stdout in JSON format
gsub_file("config/environments/production.rb", /^ +# Log to STDOUT by default\n(?: +[^# ].+\n)*/) do
  <<-RUBY
  # Configure logging as JSON to stdout.
  STDOUT.sync = true
  config.rails_semantic_logger.add_file_appender = false
  config.semantic_logger.add_appender(io: STDOUT, formatter: :json, application: "#{@app_name}")
  RUBY
end

# Configure logging tags
gsub_file("config/environments/production.rb",
          /^ *config.log_tags = \[\s*:request_id\s*\]\n/) do
  <<-RUBY
  config.log_tags = {
    request_id: :request_id,
    ip:         :remote_ip,
    referrer:   :referrer,
    user_agent: :user_agent,
  }
  RUBY
end

## Disable serving static files
gsub_file "config/environments/production.rb",
          /#\s*(config.public_file_server.enabled = false)/,
          '\1'

## Enable x_sendfile_header and assume NGINX
gsub_file "config/environments/production.rb",
          /#\s*(config.action_dispatch.x_sendfile_header = "X-Accel-Redirect")/,
          '\1'

## Enable assume_ssl as we always use a reverse proxy
gsub_file "config/environments/production.rb",
          /#\s*(config.assume_ssl = true)/,
          '\1'

## Enable host_authorization skip for /up
gsub_file "config/environments/production.rb",
          /#\s*(config.host_authorization =)/,
          '\1'

# Configure CDN assets
insert_into_file "config/environments/production.rb",
                 before: / *# Enable serving of images, stylesheets, and JavaScripts from an asset server.\n/ do
  <<-RUBY
  # Compile and serve assets from a release-specific directory.
  config.assets.prefix = ["", ENV["CDN_ASSET_PREFIX"], "assets"].compact.join("/")

  RUBY
end

gsub_file "config/environments/production.rb",
          /#\s*(config.asset_host =).*/,
          '\1 ENV["CDN_ASSET_URI"] if ENV["CDN_ASSET_URI"].present?'

# Copy production.rb to staging.rb
production_file = File.expand_path("config/environments/production.rb", destination_root)
staging_file    = File.expand_path("config/environments/staging.rb", destination_root)
say_status :clone, relative_to_original_destination_root(staging_file), config.fetch(:verbose, true)
FileUtils.cp(production_file, staging_file)

# Configure tests to use the active-job :test adapter
insert_into_file "config/environments/test.rb", after: /allow_forgery_protection = \w+\n/ do
  <<-RUBY

  # Use the test queue adapter which captures jobs on enqueue.
  config.active_job.queue_adapter = :test
  RUBY
end
