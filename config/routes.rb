Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  draw :admin

  resource :homepage, only: %i[show]

  root "homepages#show"
end
