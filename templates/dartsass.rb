#!/usr/bin/env ruby

remove_file("app/assets/stylesheets/application.css")

gem("dartsass-rails")

template("config/initializers/dartsass.rb")
template("lib/tasks/dartsass.rake")
