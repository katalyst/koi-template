# frozen_string_literal: true

module GemHelper
  # Gems added inside block will be added to a group in the Gemfile.
  #
  # Uses existing groups if present (unlike thor).
  def gem_group(*environments)
    @gem_helper = GemBuilder.new(self, environments)
    yield
  ensure
    @gem_helper = nil
  end

  # Adds a gem to the Gemfile.
  #
  # Defaults to inserting above the development, test group (unlike thor).
  def gem(gem, **options)
    (@gem_helper || GemBuilder.new(self, [])).call(gem, **options)
  end

  def unpin_gem(gem)
    if file_contains?("Gemfile", "gem \"#{gem}\"")
      gsub_file("Gemfile", /gem "#{gem}"+.+\n/, "gem \"#{gem}\"\n")
    end
  end

  class GemBuilder
    delegate_missing_to :@context

    attr_reader :environments

    def initialize(context, environments)
      @context      = context
      @environments = environments.is_a?(Symbol) ? [environments] : environments
    end

    def call(gem, **options)
      opts = options.map { |k, v| "#{k}: #{v.inspect}" }.join(", ")
      opts = ", #{opts}" unless opts.empty?

      content = "#{'  ' if nested?}gem \"#{gem}\"#{opts}\n"

      if !nested?
        puts "searching for #{group} in Gemfile"
        insert_into_file("Gemfile", content, before: "\n#{group}")
      elsif file_contains?("Gemfile", group)
        insert_into_file("Gemfile", content, after: "#{group}\n")
      else
        append_to_file("Gemfile", "#{group}\n#{content}end\n")
      end
    end

    private

    def nested?
      !@environments.empty?
    end

    def group
      # insert before development, test group by default
      environments = nested? ? @environments : %i[development test]

      "group #{environments.map(&:inspect).join(', ')} do"
    end
  end
end
