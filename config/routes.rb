Rails.application.routes.draw do
  get "/healthcheck", to: Katalyst::Healthcheck::Route.static(200, "OK")

  draw :admin

  resource :homepage, only: %i[show]

  root "homepages#show"
end
