# frozen_string_literal: true

namespace :assets do
  desc "Copy Flipper::UI assets to public/admin/flipper"
  task flipper: :environment do
    require "fileutils"
    require "flipper/ui"

    from_root = Flipper::UI.root.join("public")
    to_root   = Rails.public_path.join("admin/flipper")

    puts "Copying #{from_root} to #{to_root}"

    Dir[from_root.join("**/*.{js,jpg,jpeg,gif,png,css}")].sort.each do |from|
      to = to_root.join(Pathname(from).relative_path_from(from_root))

      FileUtils.mkdir_p(File.dirname(to))
      FileUtils.cp(from, to)
    end
  end

  # Add flipper as a dependency of precompile, so that flipper assets will be
  # available without asset hashes in production.
  task precompile: :flipper # rubocop:disable Rake/Desc
end
