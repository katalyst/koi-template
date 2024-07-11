#!/usr/bin/env ruby
# frozen_string_literal: true

return if file_contains?("Gemfile", "rspec-rails")

gem_group(:development, :test) do
  gem("factory_bot_rails")
  gem("faker")
  gem("rspec-rails")
  gem("shoulda-matchers")
end

gem_group(:test) do
  gem("capybara")
  gem("cuprite")
  gem("rack_session_access")
  gem("rails-controller-testing")
  gem("webmock")
end
