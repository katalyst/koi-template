#!/usr/bin/env ruby

gem_group :development, :test do
  gem "rubocop-katalyst", require: false
end unless file_contains?("Gemfile", "rubocop-katalyst")

template("rubocop.yml", ".rubocop.yml")
