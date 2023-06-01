# frozen_string_literal: true

require_relative "config/application"

Rails.application.load_tasks

return unless Rails.env.development? || Rails.env.test?

require "rubocop/katalyst/rake_task"
RuboCop::Katalyst::RakeTask.new

require "rubocop/katalyst/erb_lint_task"
RuboCop::Katalyst::ErbLintTask.new

require "rubocop/katalyst/prettier_task"
RuboCop::Katalyst::PrettierTask.new

# Development: compile dartsass
# Test: compile all assets and load the database config
desc "Prepare for tests by compiling necessary assets"
task "spec:prepare": Rails.env.development? ? %w[dartsass:build] : %w[assets:precompile db:setup]

desc "Run all tests"
task spec: :lint

task :default do
  puts "🎉 build complete! 🎉"
end
