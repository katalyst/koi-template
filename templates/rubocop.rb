#!/usr/bin/env ruby
# frozen_string_literal: true

gem_group(:development, :test) do
  gem("rubocop-katalyst", require: false)
  gem("erb_lint", require: false)
end

template("rubocop.yml", ".rubocop.yml")
