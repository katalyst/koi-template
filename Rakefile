# frozen_string_literal: true

require_relative "config/application"

Rails.application.load_tasks

return unless Rails.env.development? || Rails.env.test?

require "rubocop/rake_task"
RuboCop::RakeTask.new

# Development: compile dartsass
# Test: compile all assets and load the database config
desc "Prepare for tests by compiling necessary assets"
task "spec:prepare": Rails.env.development? ? %w[dartsass:build] : %w[assets:precompile db:setup]

desc "Run all linters"
task lint: %w[rubocop]

desc "Run all auto-formatters"
task format: %w[rubocop:autocorrect_all]

task spec: %w[lint]

task :default do
  puts "🎉 build complete! 🎉"
end
