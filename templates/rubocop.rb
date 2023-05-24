#!/usr/bin/env ruby

add_into_dev_test_gem_group("rubocop-katalyst", require: false)

template("rubocop.yml", ".rubocop.yml")
