# frozen_string_literal: true

ActiveSupport.on_load(:active_record) do
  version = Rails.root.join("VERSION")

  # DSN is set via SENTRY_DSN in ENV
  Sentry.init do |config|
    config.enabled_environments = %w[staging production]
    config.release              = File.read(version).strip.split("/").last if version.exist?
    filter             = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    config.before_send          = lambda do |event, _hint|
      # Sanitize extra data
      if event.extra
        event.extra = filter.filter(event.extra)
      end
      # Sanitize user data
      if event.user
        event.user = filter.filter(event.user)
      end
      # Sanitize context data (if present)
      if event.contexts
        event.contexts = filter.filter(event.contexts)
      end
      # Return the sanitized event object
      event
    end
  end
end
