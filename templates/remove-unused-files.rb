#!/usr/bin/env ruby

remove_file("app/javascript/controllers/hello_controller.js")
remove_file("config/initializers/content_security_policy.rb")
remove_file("config/initializers/inflections.rb")
remove_file("config/initializers/permissions_policy.rb")
remove_file("db/seeds.rb")
remove_dir("vendor", force: true)

template("config/locales/en.yml", force: true)
