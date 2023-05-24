# <%= @app_name %>

Katalyst project for <%= @app_name %>

## Development

To run the rails server as well as watching for dartsass changes, the application provides a Procfile (ran through foreman)
to use this, run `bin/dev` then visit `localhost`. 

Koi has been mounted automatically at `/admin`, which can be configured via the routes file.

Configures 7-in-1 SCSS folder structure.

### Prerequisites

This project uses:

  - [Ruby](https://www.ruby-lang.org/)
  - [Ruby on Rails](https://rubyonrails.org/)
  - [Postgres](https://www.postgresql.org/)
  - [RSpec](https://github.com/rspec/rspec-rails)
  - [Koi](https://github.com/katalyst/koi)
  - [Rubocop Katalyst](https://github.com/katalyst/rubocop-katalyst)
  - [Katalyst Healthcheck](https://github.com/katalyst/katalyst-healthcheck)
  - [Katalyst BasicAuth](https://github.com/katalyst/katalyst-basic-auth)
  - [Sentry](https://sentry.io)
  - [Dartsass](https://github.com/rails/dartsass-rails)

## CI/CD

This project uses [Github Actions](https://github.com/features/actions) for CI/CD.
