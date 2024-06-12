# frozen_string_literal: true

module Koi
  module Test
    module Views
      module AdminHelpers
        def default_table_component(component = nil)
          if component
            @table_component = component
          else
            @table_component || Koi::Tables::TableComponent
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.prepend_before(type: :view) do |view|
    return unless view.id.include?("spec/views/admin")

    self.controller.class.default_form_builder(Koi::FormBuilder)
    self.controller.extend(Koi::Test::Views::AdminHelpers)
  end
end
