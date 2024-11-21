# Koi Template

This project provides a base project following Katalyst best practices. It configures
* Koi
* RSpec
* Turbo + Stimulus
* Linting using Rubocop
* Basic auth
* Importmaps
* Dartsass
* Docker
* Git

## Create a new Rails project

### Prerequisites
* Make sure to have your global `rbenv` version up to date.
* Clone this repo to your local file system
* Create a new Git repo for your newly created project

### Setup
```shell
rails new sprint0 -d postgresql \
            --skip-action-cable \
            --skip-action-mailbox \
            --skip-action-mailer \
            --skip-ci \
            --skip-dev-gems \
            --skip-docker \
            --skip-git \
            --skip-jbuilder \
            --skip-kamal \
            --skip-keeps \
            --skip-system-test \
            --skip-test \
            --skip-thruster \
            -a propshaft \
            -m https://raw.githubusercontent.com/katalyst/koi-template/main/template.rb
```

 * subset of --minimal configuration
   * --skip-action-cable: we're not providing support for action_cable
   * --skip-action-mailer: we're not providing support for action_mailer
   * --skip-action-mailbox: we're not providing support for action_mailbox
   * --skip-dev-gems: we do not need dev gems
   * --skip-jbuilder: we do not need jbuilder
   * --skip-system-test: we have set up system tests with rspec and cuprite
 * --skip-test: we have set up rspec
 * --skip-bundle: we run bundle ourselves once gems are added
 * --skip-docker: we generate our own docker configuration
 * --skip-git: we have set up git to point to Katalyst github
 * --skip-keeps: we only create the keep files we need
 * -a propshaft: we use propshaft for asset pipeline
 * -m ...: set local file system path for this template

## Post-requisites

Support for Sentry is included, but need to setup Sentry separately.

## Update an existing Rails project

```shell
rails app:template LOCATION=https://raw.githubusercontent.com/katalyst/koi-template/main/template.rb
```
