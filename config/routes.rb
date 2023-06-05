Rails.application.routes.draw do
  get "/healthcheck", to: Katalyst::Healthcheck::Route.static(200, "OK")

  resource :homepage, only: %i[show]

  root "homepages#show"

  unless Rails.env.development? || Rails.env.test?
    put "/rails/active_storage/disk/:encoded_token", to: redirect("/404")
  end
  post "/rails/active_storage/direct_uploads", to: redirect("/404")
end
