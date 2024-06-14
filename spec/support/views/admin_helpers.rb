# frozen_string_literal: true

module Koi
  module Test
    module Views
      module AdminHelpers
        def default_table_component(component = nil)
          if component
            @table_component = component
          else
            @table_component || Koi::TableComponent
          end
        end

        def default_summary_table_component(component = nil)
          if component
            @summary_table_component = component
          else
            @summary_table_component || Koi::SummaryTableComponent
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.prepend_before(type: :view) do |view|
    return unless view.id.include?("spec/views/admin")

    controller.class.default_form_builder(Koi::FormBuilder)
    controller.extend(Koi::Test::Views::AdminHelpers)
  end
end
