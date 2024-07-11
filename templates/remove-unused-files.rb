#!/usr/bin/env ruby
# frozen_string_literal: true

remove_file("app/javascript/controllers/hello_controller.js")
remove_file("config/initializers/content_security_policy.rb")
remove_file("config/initializers/inflections.rb")
remove_file("config/initializers/permissions_policy.rb")

# this is installed when `rails action_text:install` is ran - these file are not needed
remove_file("app/assets/stylesheets/actiontext.css")
remove_dir("app/views/active_storage")
remove_dir("app/views/layouts/action_text")
run("bin/importmap unpin trix")
run("bin/importmap unpin @rails/actiontext")
gsub_file("app/javascript/application.js", "import \"trix\"\n", "")
gsub_file("app/javascript/application.js", "import \"@rails/actiontext\"\n", "")

gsub_file("Gemfile", /ruby "+.[[:graph:]]+"/, "")

template("config/locales/en.yml", force: true)
