# frozen_string_literal: true

# Run using bin/ci

CI.run do
  step "Setup", "bin/setup --skip-server"

  step "Style: Ruby", "bin/rubocop"

  step "Style: Erb", "bundle exec rake erb_lint:lint"

  step "Style: JS/CSS", "bundle exec rake prettier:lint"

  step "Security: Importmap vulnerability audit", "bin/importmap audit"

  assets = ENV["CI"] ? "assets:precompile" : "dartsass:build"
  step "Precompile assets", "bundle exec rails #{assets}"

  step "Tests: rspec", "bundle exec rspec"
end
