#!/usr/bin/env ruby

return if file_contains?("Gemfile", "rspec-rails")

gem_group("development", "test") do
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec-rails"
  gem "shoulda-matchers"
end

gem_group("test") do
  gem "capybara"
  gem "cuprite"
  gem "rack_session_access"
  gem "rails-controller-testing"
  gem "webmock"
end

copy_file("spec/rails_helper.rb")
copy_file("spec/spec_helper.rb")
copy_file("spec/support/capybara.rb")
