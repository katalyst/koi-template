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
      browser_options: {
        "no-sandbox":            nil, # required for docker (github-ci)
        "disable-dev-shm-usage": nil, # helps speed up chrome startup in CI env
        "disable-gpu":           nil, # helps speed up chrome startup in CI env
      },
      process_timeout: 20, # default is 10. Wait longer for Chrome initial startup.
      # block hosts that are not required for tests
      url_blacklist:   [
        %r{//fonts.googleapis.com}, # inconsolata, etc
        %r{//rsms.me}, # inter
      ],
    }
  end

  config.include Capybara::RSpecMatchers, type: :request
end
