Rails.application.routes.draw do
  get "/healthcheck", to: Katalyst::Healthcheck::Route.static(200, "OK")

  mount Koi::Engine => "/admin", as: "koi_engine"
end
