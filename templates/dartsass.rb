#!/usr/bin/env ruby
# frozen_string_literal: true

remove_file("app/assets/stylesheets/application.css")

gem("dartsass-rails")

template("config/initializers/dartsass.rb")
