Rails.application.routes.draw do
  get "/healthcheck", to: Katalyst::Healthcheck::Route.static(200, "OK")

  resource :homepage, only: %i[show]

  root "homepages#show"

  mount Koi::Engine => "/admin", as: "koi_engine"
end
