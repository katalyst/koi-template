# Koi Template

This project provides a base project following Katalyst best practices. It configures
* Koi
* RSpec
* Turbo + Stimulus
* Linting using Rubocop
* Basic auth
* Healthcheck
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
```
rails new sprint0 -d postgresql \
            --skip-action-cable \
            --skip-action-mailer \
            --skip-action-mailbox \
            --skip-active-job \
            --skip-bootsnap \
            --skip-dev-gems \
            --skip-jbuilder \
            --skip-system-test \
            --skip-test \
            --skip-git \
            --skip-keeps \
            -a propshaft \
            -m https://raw.githubusercontent.com/katalyst/koi-template/main/template.rb
```

 * subset of --minimal configuration
   * --skip_action_cable: we're not providing support for action_cable
   * --skip_action_mailer: we're not providing support for action_mailer
   * --skip_action_mailbox: we're not providing support for action_mailbox
   * --skip_active_job: we're not providing support for active_job
   * --skip_bootsnap: we're not using bootsnap
   * --skip_dev_gems: we do not need dev gems
   * --skip_jbuilder: we do not need jbuilder
   * --skip_system_test: we have set up system tests with rspec and cuprite 
 * --skip-test: we have set up rspec
 * --skip-bundle: we run bundle ourselves once gems are added
 * --skip-git: we have set up git to point to Katalyst github
 * --skip-keeps: we only create the keep files we need
 * -a propshaft: we use propshaft for asset pipeline
 * -m ...: set local file system path for this template

## Post-requisites

Support for Sentry is included, but need to setup Sentry separately.
