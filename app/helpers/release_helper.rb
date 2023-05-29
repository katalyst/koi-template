# frozen_string_literal: true

module ReleaseHelper
  class CurrentVcsRelease
    include Singleton

    VERSION_FILE  = Rails.root.join("VERSION").freeze
    REVISION_FILE = Rails.root.join("REVISION").freeze

    def version
      @version ||= read(VERSION_FILE)
    end

    def revision
      @revision ||= read(REVISION_FILE)
    end

    private

    def read(file)
      return "HEAD" if Rails.env.development?
      return "unknown" unless File.exist?(file)

      File.read(file).strip
    end
  end

  def release_meta_tags
    capture do
      concat tag.meta(name: "application-version", content: CurrentVcsRelease.instance.version)
      concat "\n  "
      concat tag.meta(name: "application-revision", content: CurrentVcsRelease.instance.revision)
    end
  end
end
