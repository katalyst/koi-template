#!/usr/bin/env ruby

gem_group(:development, :test) do
  gem("rubocop-katalyst", require: false)
  gem("erb_lint", require: false)
end

template("rubocop.yml", ".rubocop.yml")
