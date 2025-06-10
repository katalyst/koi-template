# <%= @app_name %>

Katalyst project for <%= @app_name %>.

## Development

Run `bin/dev` to start foreman then visit `localhost`.

### Admin

Koi has been mounted automatically at `/admin`, which can be configured via the
routes file.

You will need to create an admin user to access `/admin`. In
production and staging environments you can do this by getting a shell on an
instance using `bin/ecs-ssh`.

```ruby
bin/admin-adduser
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
  - [Katalyst BasicAuth](https://github.com/katalyst/katalyst-basic-auth)
  - [Sentry](https://sentry.io)

## CI/CD

This project uses [Github Actions](https://github.com/features/actions) for CI/CD.
