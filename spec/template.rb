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

root = Pathname.new(__dir__).join("..")
root.glob("spec/system/**/*_spec.rb").sort.each do |f|
  copy_file(f.relative_path_from(root))
end
