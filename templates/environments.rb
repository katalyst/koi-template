#!/usr/bin/env ruby

# Use rails_semantic_logger to log to stdout in JSON format
gsub_file("config/environments/production.rb", /^ *# Log to STDOUT by default.*\n/) do
  <<-RUBY
  # Configure logging as JSON to stdout
  STDOUT.sync = true
  config.rails_semantic_logger.add_file_appender = false
  config.semantic_logger.add_appender(io: STDOUT, formatter: :json, application: "#{@app_name}")
  RUBY
end

# Remove default logging configuration.
# Using multiline regex to match
# multiline regex ignores whitespace, so \s is used instead of actual spaces
gsub_file "config/environments/production.rb",
          /
            config.logger\s=\sActiveSupport::Logger.new\(STDOUT\)\n
            \s*.tap\s*{\s\|logger\|\slogger.formatter\s=\s::Logger::Formatter.new\s}\n
            \s*.then\s{\s\|logger\|\sActiveSupport::TaggedLogging.new\(logger\)\s}\n
          /x,
          ""

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

gsub_file("config/environments/production.rb",
          /^\s*# config.asset_host =.*\n/) do
  <<-RUBY
  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  if ENV["CDN_ASSET_PREFIX"].present?
    config.assets.prefix = "/#\{ENV["CDN_ASSET_PREFIX"]\}/assets"
  else
    config.assets.prefix = "/assets"
  end

  if ENV["CDN_ASSET_URI"].present?
    config.asset_host = ENV["CDN_ASSET_URI"]
  end
  RUBY
end

# Copy production.rb to staging.rb
production_file = File.expand_path("config/environments/production.rb", destination_root)
staging_file    = File.expand_path("config/environments/staging.rb", destination_root)
say_status :clone, relative_to_original_destination_root(staging_file), config.fetch(:verbose, true)
FileUtils.cp(production_file, staging_file)
