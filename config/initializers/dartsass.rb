# frozen_string_literal: true

Rails.application.config.dartsass.builds = {
  "application.scss"   => "application.css",
  "koi/koi-admin.scss" => "koi/admin.css",
}

Rails.application.config.dartsass.build_options = "--quiet-deps"
