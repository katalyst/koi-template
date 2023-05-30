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
  setup_release_tag
  setup_routes

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

    run("rake format || true")
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
  if __FILE__ =~ %r{\Ahttps?://}
    require "tmpdir"
    source_paths.unshift(tempdir = Dir.mktmpdir("koi-template-"))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
                 "--quiet",
                 "https://github.com/katalyst/koi-template.git",
                 tempdir
               ].map(&:shellescape).join(" ")

    if (branch = __FILE__[%r{koi-template/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
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

  add_gem_above_groups("katalyst-basic-auth", github: "katalyst/katalyst-basic-auth")
end

def setup_healthcheck
  add_gem_above_groups("katalyst-healthcheck")
end

def setup_sentry
  add_gem_above_groups("sentry-rails")

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
  directory("app/assets/stylesheets")
end

def remove_unused_files
  apply "templates/remove-unused-files.rb"
end

def override_default_files
  apply("templates/override-default-files.rb")
end

def cleanup_gemfile
  gsub_file("Gemfile", /^\s*#\s*.*\n/, '')
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
  gsub_file(".gitignore", /^\s*#\s*TODO.*\n/, '')
  append_to_file(".gitignore", "app/assets/builds/*\n!/app/assets/builds/.keep")

  git(:init)
  git(add: "-A")
  git(commit: "-m 'Initial commit'")
  git(remote: "add origin git@github.com:katalyst/#{@app_name.dasherize}.git")
end

def file_exists?(file)
  File.exist?(file)
end

def file_contains?(file, contains)
  return false unless file_exists?(file)

  File.foreach(file).any? { |line| line.include?(contains) }
end

def add_gem_above_groups(gem, options = {})
  if options.any?
    insert_into_file("Gemfile", "gem '#{gem}', #{options.map { |k, v| "#{k}: #{v.inspect}" }.join(", ")}\n", :before => "\ngroup :development, :test do")
  else
    insert_into_file("Gemfile", "gem '#{gem}'\n", :before => "\ngroup :development, :test do")
  end
end

def add_into_dev_test_gem_group(gem, options = {})
  if file_contains?("Gemfile", "group :development, :test do")
    if options.any?
      insert_into_file("Gemfile", "gem '#{gem}', #{options.map { |k, v| "#{k}: #{v.inspect}" }.join(", ")}\n", :after => "group :development, :test do\n")
    else
      insert_into_file("Gemfile", "gem '#{gem}'\n", :after => "group :development, :test do\n")
    end
  else
    gem_group :development, :test do
      gem gem, **options
    end
  end
end

def add_into_test_gem_group(gem, options = {})
  if file_contains?("Gemfile", "group :test do")
    if options.any?
      insert_into_file("Gemfile", "gem '#{gem}', #{options.map { |k, v| "#{k}: #{v.inspect}" }.join(", ")}\n", :after => "group :test do\n")
    else
      insert_into_file("Gemfile", "gem '#{gem}'\n", :after => "group :test do\n")
    end
  else
    gem_group :test do
      gem gem, **options
    end
  end
end

def unpin_gem(gem)
  if file_contains?("Gemfile", "gem \"#{gem}\"")
    gsub_file("Gemfile", /gem \"#{gem}\"+.+\n/, "gem \"#{gem}\"\n")
  end
end

apply_template!
