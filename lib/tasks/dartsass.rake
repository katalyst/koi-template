# frozen_string_literal: true

# Katalyst extensions to the dartsass task provided by the rails-dartsass gem

def dartsass_load_paths
  [CSS_LOAD_PATH].concat(Rails.application.config.assets.paths)
    .reject { |path| %r{app/assets/builds$}.match?(path.to_s) }
    .map { |path| "--load-path #{path}" }
    .join(" ")
end

# rubocop:disable Rake/Desc
namespace :dartsass do
  task clobber: :environment do
    # dartsass currently only removes top-level css files, but not koi/*
    sh "rm -rf app/assets/builds/*"
  end
end
# rubocop:enable Rake/Desc
