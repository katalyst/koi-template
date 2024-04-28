# frozen_string_literal: true

module Admin
  class ApplicationController < ActionController::Base
    include Koi::Controller::IsAdminController

    authenticate_local_admins Rails.env.development?

    helper Koi::ApplicationHelper
    helper Koi::DefinitionListHelper
  end
end
