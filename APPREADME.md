# <%= @app_name %>

Katalyst project for <%= @app_name %>

## Setup

```
bin/setup
rails importmap:install
rails turbo:install
rails stimulus:install
rails dartsass:install
```

### Setup notes
`rails dartsass:install` will also create and configure [foreman](https://github.com/ddollar/foreman) 

### Prerequisites

This project uses:

  - [Ruby](https://www.ruby-lang.org/)
  - [Ruby on Rails](https://rubyonrails.org/)
  - [Koi](https://github.com/katalyst/koi)
  - [Postgres](https://www.postgresql.org/)
  - [Rubocop-Katalyst](https://github.com/katalyst/rubocop-katalyst)
