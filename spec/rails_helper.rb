# frozen_string_literal: true

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"
# require "webmock/rspec"
require "shoulda/matchers"
# require "active_storage_validations/matchers"

WebMock.disable_net_connect!(allow_localhost: true)

# Include support helpers
Rails.root.glob("spec/support/**/*.rb").each { |f| require f }

# Apply pending migrations
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip # rubocop:disable RSpec/Output
  exit 1
end

RSpec.configure do |config|
  config.filter_rails_from_backtrace!
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true

  # config.include ActiveStorageValidations::Matchers
  config.include FactoryBot::Syntax::Methods
  # config.include Koi::Controller::HasAdminUsers::Test::ViewHelper, type: :view
  # config.include SystemHelper, type: :system

  %i[model form].each do |type|
    config.include(Shoulda::Matchers::ActiveModel, type:)
    config.include(Shoulda::Matchers::ActiveRecord, type:)
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
