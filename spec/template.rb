#!/usr/bin/env ruby

return if file_contains?("Gemfile", "rspec-rails")

add_into_dev_test_gem_group("factory_bot_rails")
add_into_dev_test_gem_group("faker")
add_into_dev_test_gem_group("rspec-rails")
add_into_dev_test_gem_group("shoulda-matchers")

add_into_test_gem_group("capybara")
add_into_test_gem_group("cuprite")
add_into_test_gem_group("rack_session_access")
add_into_test_gem_group("rails-controller-testing")
add_into_test_gem_group("webmock")
