#!/usr/bin/env ruby

remove_file("app/assets/stylesheets/application.css")

add_gem_above_groups("dartsass-rails")

template("config/initializers/dartsass.rb")
template("lib/tasks/dartsass.rake")
