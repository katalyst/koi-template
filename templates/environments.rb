#!/usr/bin/env ruby
# frozen_string_literal: true

# Configure logging
gsub_file("config/environments/production.rb",
          / +# Log to STDOUT with.*\n\s+config.log_tags\s+=.*\n\s+config.logger\s+=.*\n/) do
  <<-RUBY
  # Log to STDOUT as JSON.
  $stdout.sync = true
  config.rails_semantic_logger.add_file_appender = false
  config.semantic_logger.add_appender(io: $stdout, formatter: :json, application: "cotl-www")

  # Include request metadata in tagged logs.
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
