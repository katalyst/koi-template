fail("Rails 7.0.0 or greater is required") if Rails.version <= "7"

def apply_template!
  add_template_repository_to_source_path

  setup_readme
  setup_secrets
  setup_rubocop
  setup_rspec
  setup_github_actions
  setup_dartsass
  setup_database
  setup_rakefile
  setup_staging
  setup_timezone
  setup_routes

  run("bin/setup")

  after_bundle do
    remove_unused_files
    install_dartsass
    run("rake format || true")
    run("bundle lock --add-platform arm64-linux")
    run("bundle lock --add-platform x86_64-linux")
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

def setup_github_actions
  template("github/workflows/test.yml", ".github/workflows/test.yml", force: true)
end

def setup_dartsass
  apply "templates/dartsass.rb"
end

def setup_database
  template("config/database.yml", force: true)
end

def setup_rakefile
  template("Rakefile", force: true)
end

def setup_staging
  copy_file("config/environments/production.rb", "config/environments/staging.rb")
end

def setup_timezone
  uncomment_lines("config/application.rb", /config[.]time_zone/)
  gsub_file("config/application.rb", "Central Time (US & Canada)", "Adelaide")
end

def setup_routes
  template("config/routes.rb", force: true)
end

def remove_unused_files
  apply "templates/remove-unused-files.rb"
end

def install_dartsass
  run("rails dartsass:install")
end

def configure_git
  get("https://raw.githubusercontent.com/github/gitignore/main/Rails.gitignore", ".gitignore")
  gsub_file(".gitignore", /^\s*#\s*TODO.*\n/, '')

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
