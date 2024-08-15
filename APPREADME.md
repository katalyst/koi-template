# <%= @app_name %>

Katalyst project for <%= @app_name %>.

## Development

To run the rails server as well as watching for dartsass changes, the
application provides a Procfile (run through foreman) to use this, run `bin/dev`
then visit `localhost`.

<% if @add_koi %>
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
<% end %>
### Prerequisites

This project uses:

  - [Ruby](https://www.ruby-lang.org/)
  - [Ruby on Rails](https://rubyonrails.org/)
  - [Postgres](https://www.postgresql.org/)
  - [RSpec](https://github.com/rspec/rspec-rails)
<% if @add_koi %>- [Koi](https://github.com/katalyst/koi)<% end %>
  - [Rubocop Katalyst](https://github.com/katalyst/rubocop-katalyst)
  - [Katalyst BasicAuth](https://github.com/katalyst/katalyst-basic-auth)
  - [Sentry](https://sentry.io)
  - [Dartsass](https://github.com/rails/dartsass-rails)

## CI/CD

This project uses [Github Actions](https://github.com/features/actions) for CI/CD.
