# frozen_string_literal: true

module Admin
  class ApplicationController < ActionController::Base
    include Koi::Controller::IsAdminController
    include Katalyst::Tables::Backend
    include Pagy::Backend

    authenticate_local_admins Rails.env.development?

    default_form_builder "Koi::FormBuilder"

    helper Katalyst::GOVUK::Formbuilder::Frontend
    helper Koi::ApplicationHelper
    helper Koi::DefinitionListHelper
  end
end
