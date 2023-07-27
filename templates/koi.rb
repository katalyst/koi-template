#!/usr/bin/env ruby

gem("katalyst-koi")

# koi requires action_text
uncomment_lines("config/application.rb", /action_text/)
uncomment_lines("config/application.rb", /action_mailer/)
uncomment_lines("config/application.rb", /active_storage/)

# sets up initial admin account
append_file("db/seeds.rb", "Koi::Engine.load_seed")

# adds navigation items to admin menu
template("config/initializers/koi.rb")

copy_file("config/storage.yml")

root = Pathname.new(__dir__).join("..")
root.glob("app/{controllers}/admin/**/*.rb").sort.each do |f|
  copy_file(f.relative_path_from(root))
end

# update application.rb configuration with Koi defaults
gsub_file("config/application.rb",
          /^\s+# Don't generate system test files.\n\s+config.generators.system_tests = nil\n/) do
  <<-RUBY

    # Configure koi-style generators
    config.generators do |g|
      g.assets(false)
      g.helper(false)
      g.stylesheets(false)
      g.test_framework(:rspec)
    end

    # Ensure that Koi loads immediately after main app and before all other engines
    config.railties_order = [:main_app, Koi::Engine, :all]
  RUBY
end

insert_into_file("app/controllers/application_controller.rb", "\n\tinclude Katalyst::Navigation::HasNavigation\n",
                 after: "class ApplicationController < ActionController::Base\n")
