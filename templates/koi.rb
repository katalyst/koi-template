#!/usr/bin/env ruby

add_gem_above_groups("koi", github: "katalyst/koi")

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

# ensure load paths are correct for engines
insert_into_file("config/application.rb", "\n\tconfig.railties_order = [:main_app, Koi::Engine, :all]\n", :after => "config.generators.system_tests = nil\n")
