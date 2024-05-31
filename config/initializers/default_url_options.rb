hosts = {
  development: "https://localhost",
  staging:     "https://#{@app_name}-staging.katalyst.com.au",
  production:  "https://#{@app_name}-production.katalyst.com.au",
  test:        "https://example.com",
}.freeze

Rails.application.routes.default_url_options = { host: hosts[Rails.env.to_sym] }
