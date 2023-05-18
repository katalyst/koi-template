#!/usr/bin/env ruby

remove_file("app/assets/stylesheets/application.css")

unless file_contains?("Gemfile", "dartsass-rails")
  gem "dartsass-rails"
end

