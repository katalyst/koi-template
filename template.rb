# frozen_string_literal: true

fail("Rails 7.0.0 or greater is required") if Rails.version <= "7"

def apply_template!
  add_template_repository_to_source_path

  setup_readme
  setup_rubocop
  setup_rspec
  setup_basic_auth
  setup_sentry
  setup_github_actions
  setup_flipper
  setup_database
  setup_search
  setup_seeds
  setup_foreman
  setup_rakefile
  setup_timezone
  setup_koi
  setup_homepage
  setup_release_tag
  setup_routes
  setup_ecs
  setup_logger
  setup_active_storage
  setup_puma

  cleanup_gemfile

  after_bundle do
    setup_secrets
    setup_environments
    setup_stylesheets

    install_active_storage
    install_flipper
    install_koi

    remove_unused_files
    override_default_files

    setup_layout

    run("rake db:prepare db:migrate")

    run("rubocop -A || rubocop --auto-gen-config")
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
  gem("katalyst-basic-auth")
end

def setup_sentry
  gem("sentry-rails")

  template("config/initializers/sentry.rb")
end

def setup_github_actions
  remove_file(".github/workflows/ci.yml")
  directory("github", ".github", force: true)
end

def setup_flipper
  apply "templates/flipper.rb"
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

def setup_search
  case options[:database]
  when "postgresql"
    gem "pg_search"
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
  template("Rakefile.template", "Rakefile", force: true)
end

def setup_timezone
  uncomment_lines("config/application.rb", /config[.]time_zone/)
  gsub_file("config/application.rb", "Central Time (US & Canada)", "Adelaide")
end

def setup_logger
  gem("rails_semantic_logger")
end

def setup_active_storage
  gem("aws-sdk-s3")
end

def setup_puma
  apply "templates/puma.rb"
end

# Use rails_semantic_logger to log to stdout in JSON format
def setup_environments
  apply "templates/environments.rb"
end

def setup_koi
  apply("templates/koi.rb")
end

def setup_layout
  apply("templates/layout.rb")
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

def install_active_storage
  run("rails active_storage:install")
  {
    development: :local,
    test:        :test,
    staging:     :s3,
    production:  :s3,
  }.each do |env, service|
    gsub_file "config/environments/#{env}.rb",
              /(config.active_storage.service =).+/,
              "\\1 #{service.inspect}"
  end
end

def install_flipper
  run("rails g flipper:setup")
end

def install_koi
  run("rails action_text:install")
  run("rails koi:install:migrations")
  run("rails katalyst_content:install:migrations")
  run("rails katalyst_navigation:install:migrations")
end

def add_docker
  directory("docker", mode: :preserve)
  template(".dockerignore", force: true)
end

def configure_git
  get("https://raw.githubusercontent.com/github/gitignore/main/Rails.gitignore", ".gitignore")

  gsub_file(".gitignore", /^\s*#\s*TODO.*\n/, "")

  append_to_file(".gitignore", "app/assets/builds/*")
  append_to_file(".gitignore", "\n!/app/assets/builds/.keep")
  append_to_file(".gitignore", "\n/public/admin/flipper")

  if ENV["CI"]
    git(config: "--global user.name Katalyst CI")
    git(config: "--global user.email devs@katalyst.com.au")
  end

  git(:init)
  git(add: "-A")
  git(commit: "-m 'Initial commit'")

  git(remote: "add origin git@github.com:katalyst/#{ecs_name}.git") unless ENV["CI"]
end

def setup_ecs
  template("config/ecs.env")
end

def ecs_name(env = nil)
  [app_name.dasherize, env].compact.join("-")
end

apply_template!
