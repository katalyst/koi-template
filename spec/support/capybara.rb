# frozen_string_literal: true

require "capybara/cuprite"
require "capybara/rspec"
require "rack_session_access/capybara"

RSpec.configure do |config|
  Capybara.default_driver = Capybara.javascript_driver = :cuprite

  Capybara.server            = :puma, { Silent: true }
  Capybara.disable_animation = true

  # Rails will set `:selenium` as the runner for system tests by default, but this happens after `before` hooks.
  # We want to use our configured javascript driver and ensure that this is set before
  # our before hooks run so that we can log in (etc).
  config.prepend_before(:all, type: :system) do
    driven_by :cuprite, screen_size: [1920, 1080], options: {
      headless:        true,
      inspector:       false,
      # required for docker (github-ci)
      browser_options: { "no-sandbox": nil },
      # block hosts that are not required for tests
      url_blacklist:   [
        # %r{google-analytics\.com}, # Google Analytics
      ],
    }
  end

  config.include Capybara::RSpecMatchers, type: :request
end
