# frozen_string_literal: true

require "capybara/rspec"
require "rack_session_access/capybara"
require "capybara/cuprite"

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(app, headless: true, debug: true, window_size: [1920, 1080])
end

RSpec.configure do
  Capybara.default_driver = Capybara.javascript_driver = :cuprite

  Capybara.server                = :puma, { Silent: true }
  Capybara.disable_animation     = true
end
