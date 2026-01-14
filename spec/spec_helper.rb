# frozen_string_literal: true

RSpec.configure do |config|
  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  config.example_status_persistence_file_path = "tmp/examples.txt"

  RSpec::Matchers.define_negated_matcher :not_change, :change
end
