# frozen_string_literal: true

ActiveSupport.on_load(:active_record) do
  version = Rails.root.join("VERSION")

  # DSN is set via SENTRY_DSN in ENV
  Sentry.init do |config|
    config.enabled_environments = %w[staging production]
    config.release              = File.read(version).strip.split("/").last if version.exist?
    filter             = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    config.before_send = lambda do |event, _hint|
      filter.filter(event.to_hash)
    end
  end
end
