# <%= @app_name %>

Katalyst project for <%= @app_name %>.

## Development

To run the rails server as well as watching for dartsass changes, the
application provides a Procfile (ran through foreman) to use this, run `bin/dev`
then visit `localhost`.

### Admin

Koi has been mounted automatically at `/admin`, which can be configured via the
routes file.

You will need to create an admin user from the console to access `/admin`. In
production and staging environments you can do this by getting a shell on an
instance using `bin/ecs-ssh`.

```ruby
require "securerandom"
password = SecureRandom.base58(16)
puts "Your temporary password is #{password}"
Admin::User.create(name: `id -F`.strip, email: "#{ENV['USER']}@katalyst.com.au", password:)
```

If your username matches your Katalyst email address then when you're running
locally with local admin enabled in AdminController then you will be
automatically signed in as yourself. 

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
