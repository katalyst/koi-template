fail("Rails 7.0.0 or greater is required") if Rails.version <= "7"

def apply_template!
  add_template_repository_to_source_path

  setup_readme
  setup_rubocop
  setup_rspec
  setup_basic_auth
  setup_healthcheck
  setup_sentry
  setup_github_actions
  setup_dartsass
  setup_database
  setup_seeds
  setup_rakefile
  setup_timezone
  setup_koi
  setup_homepage
  setup_routes

  after_bundle do
    setup_secrets
    setup_staging
    setup_stylesheets

    install_dartsass
    install_koi

    remove_unused_files
    override_default_files

    run("bin/setup")

    run("rake format || true")
    run("bundle lock --add-platform aarch64-linux")
    run("bundle lock --add-platform x86_64-linux")

    add_docker
    configure_git
  end
end

def add_template_repository_to_source_path
  source_paths.unshift(File.dirname(__FILE__))
end

def setup_readme
  template("APPREADME.md", "README.md", force: true)
end

def setup_secrets
  apply "templates/secrets.rb"
end

def setup_rubocop
  apply "templates/rubocop.rb"
end

def setup_rspec
  apply "spec/template.rb"
end

def setup_basic_auth
  gem "katalyst-basic-auth", git: "https://github.com/katalyst/katalyst-basic-auth"
end

def setup_healthcheck
  gem "katalyst-healthcheck"
end

def setup_sentry
  gem "sentry-rails"

  template("config/initializers/sentry.rb")
end

def setup_github_actions
  root = Pathname.new(__dir__)
  root.glob("github/workflows/*.yml").sort.each do |f|
    template(f.relative_path_from(root), ".#{f.relative_path_from(root)}", force: true)
  end
end

def setup_dartsass
  apply "templates/dartsass.rb"
end

def setup_database
  template("config/database.yml", force: true)
end

def setup_seeds
  template("db/seeds.rb", force: true)
end

def setup_rakefile
  template("Rakefile", force: true)
end

def setup_staging
  template("config/environments/production.rb", "config/environments/staging.rb")
end

def setup_timezone
  uncomment_lines("config/application.rb", /config[.]time_zone/)
  gsub_file("config/application.rb", "Central Time (US & Canada)", "Adelaide")
end

def setup_koi
  apply("templates/koi.rb")
end

def setup_homepage
  template("app/controllers/homepages_controller.rb")
  template("app/views/homepages/show.html.erb")
end

def setup_routes
  template("config/routes.rb", force: true)
end

def setup_stylesheets
  root = Pathname.new(__dir__)
  root.glob("app/assets/stylesheets/**/*.scss").sort.each do |f|
    copy_file(f.relative_path_from(root), force: true)
  end
end

def remove_unused_files
  apply "templates/remove-unused-files.rb"
end

def override_default_files
  apply("templates/override-default-files.rb")
end

def install_koi
  run("rails koi:install:migrations")
  run("rails katalyst_content:install:migrations")
  run("rails katalyst_navigation:install:migrations")
  run("rails action_text:install")
end

def install_dartsass
  run("rails dartsass:install")
end

def add_docker
  root = Pathname.new(__dir__)
  root.glob("docker/**/*").reject { |f| File.directory?(f) }.sort.each do |f|
    copy_file(f.relative_path_from(root), force: true)
  end
end

def configure_git
  get("https://raw.githubusercontent.com/github/gitignore/main/Rails.gitignore", ".gitignore")
  gsub_file(".gitignore", /^\s*#\s*TODO.*\n/, '')
  append_to_file(".gitignore", "app/assets/builds/*\n!/app/assets/builds/.keep")

  git(:init)
  git(add: "-A")
  git(commit: "-m 'Initial commit'")
  git(remote: "add origin git@github.com:katalyst/#{@app_name}.git")
end

def file_exists?(file)
  File.exist?(file)
end

def file_contains?(file, contains)
  return false unless file_exists?(file)

  File.foreach(file).any? { |line| line.include?(contains) }
end

apply_template!
