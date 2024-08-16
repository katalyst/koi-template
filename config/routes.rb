# frozen_string_literal: true

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resource :homepage, only: %i[show]

  root "homepages#show"
end
