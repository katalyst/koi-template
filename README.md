# Koi Template

## Create a new Rails project

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
            -m koi-template/template.rb
```

 * ~~--minimal: creates a minimal rails project (https://github.com/rails/rails/pull/39282)~~
   * subset of --minimal configuration
   * --skip_action_cable
   * --skip_action_mailer
   * --skip_action_mailbox
   * --skip_active_job
   * --skip_bootsnap
   * --skip_dev_gems
   * --skip_jbuilder
   * --skip_system_test
 * --skip-test: we're going to set up rspec
 * --skip-bundle: we're going to run bundle ourselves once gems are added
 * --skip-git: we're going to set up git and point it at Katalyst github
 * --skip-keeps: we're going to create only the keep files we need
 * -m ...: use this template after creating the bare project 
 * -a propshaft: use propshaft for assets

### Notes
 * Make sure to have your global `rbenv` version up to date.
