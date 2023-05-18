# frozen_string_literal: true

RSpec.configure do |config|
  RSpec::Matchers.define_negated_matcher :not_change, :change
end
