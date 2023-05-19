# frozen_string_literal: true

ActiveSupport.on_load(:active_record) do
  # DSN is set via SENTRY_DSN in ENV
  Sentry.init do |config|
    filter             = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    config.before_send = lambda do |event, _hint|
      filter.filter(event.to_hash)
    end
  end
end
