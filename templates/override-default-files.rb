#!/usr/bin/env ruby
# frozen_string_literal: true

if @add_koi
  directory("bin", force: true, mode: :preserve)
  directory("spec", force: true, exclude_pattern: /template.rb/)
  insert_into_file("config/initializers/dartsass.rb", "\"admin.scss\"       => \"admin.css\",", after: "\"application.css\",\n")
  insert_into_file("config/initializers/dartsass.rb", "Koi.config.admin_stylesheet = \"admin\"", after: "# frozen_string_literal: true\n")
  route("draw :admin")
else
  directory("bin", force: true, mode: :preserve, exclude_pattern: /admin-adduser/)
  directory("spec", force: true, exclude_pattern: /admin_/)
  remove_file("spec/template.rb")
end

directory("public", force: true)
