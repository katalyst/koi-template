# frozen_string_literal: true

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
  setup_foreman
  setup_rakefile
  setup_timezone
  setup_koi
  setup_homepage
  setup_release_tag
  setup_routes
  setup_ecs

  cleanup_gemfile

  after_bundle do
    setup_secrets
    setup_staging
    setup_stylesheets

    install_dartsass
    install_koi

    remove_unused_files
    override_default_files

    run("rake db:prepare db:migrate")

    run("rubocop -A || true")
    run("rake autocorrect || true")
    run("bundle lock --add-platform aarch64-linux")
    run("bundle lock --add-platform x86_64-linux")

    add_docker
    configure_git
  end
end

# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
#
# Based on https://github.com/mattbrictson/rails-template/blob/main/template.rb
def add_template_repository_to_source_path
  if __FILE__.match?(%r{\Ahttps?://})
    require "tmpdir"
    template_root = Dir.mktmpdir("koi-template-")
    at_exit { FileUtils.remove_entry(template_root) }
    git clone: [
      "--quiet",
      "https://github.com/katalyst/koi-template.git",
      template_root,
    ].map(&:shellescape).join(" ")

    if (branch = __FILE__[%r{koi-template/(.+)/template.rb}, 1])
      Dir.chdir(template_root) { git checkout: branch }
    end
  else
    template_root = __dir__
  end

  source_paths.unshift(template_root)

  # Load helpers from the `templates/helpers` directory
  Pathname.new(template_root).glob("templates/helpers/*.rb").each do |helper|
    require(helper)
    extend Pathname.new(helper).basename.sub_ext("").to_s.camelize.constantize
  end
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
  gem("katalyst-basic-auth", github: "katalyst/katalyst-basic-auth")
end

def setup_healthcheck
  gem("katalyst-healthcheck")
end

def setup_sentry
  gem("sentry-rails")

  template("config/initializers/sentry.rb")
end

def setup_github_actions
  directory("github", ".github")
end

def setup_dartsass
  apply "templates/dartsass.rb"
end

def setup_database
  case options[:database]
  when "postgresql"
    template("config/database.postgres.yml", "config/database.yml", force: true)
  when "sqlite3"
    copy_file("config/database.sqlite.yml", "config/database.yml", force: true)
  else
    raise "Unsupported database: #{options[:database]}"
  end
end

def setup_seeds
  template("db/seeds.rb", force: true)
end

def setup_foreman
  gem_group(:development) do
    gem("foreman", require: false)
  end
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
  directory("config/routes")
  template("config/routes.rb", force: true)
end

def setup_stylesheets
  directory("app/assets/stylesheets")
end

def remove_unused_files
  apply "templates/remove-unused-files.rb"
end

def override_default_files
  apply("templates/override-default-files.rb")
end

def cleanup_gemfile
  gsub_file("Gemfile", /^\s*#\s*.*\n/, "")
  unpin_gem("pg")
  unpin_gem("puma")
  unpin_gem("rails")
end

def setup_release_tag
  apply "templates/release-tag.rb"
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
  directory("docker", mode: :preserve)
end

def configure_git
  get("https://raw.githubusercontent.com/github/gitignore/main/Rails.gitignore", ".gitignore")
  gsub_file(".gitignore", /^\s*#\s*TODO.*\n/, "")
  append_to_file(".gitignore", "app/assets/builds/*\n!/app/assets/builds/.keep")

  if ENV["CI"]
    git(config: "--global user.name Katalyst CI")
    git(config: "--global user.email devs@katalyst.com.au")
  end

  git(:init)
  git(add: "-A")
  git(commit: "-m 'Initial commit'")

  git(remote: "add origin git@github.com:katalyst/#{@app_name.dasherize}.git") unless ENV["CI"]
end

def setup_ecs
  template("config/ecs.env")
end

apply_template!
