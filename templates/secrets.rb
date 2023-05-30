#!/usr/bin/env ruby

def create_secret
  run("rails secret", capture: true)
end

def write_secret_key_base(secret, environment)
  run("EDITOR='echo secret_key_base: #{secret} > ' rails credentials:edit --environment=#{environment}")
end

# Rails generates a master key but we don't want to risk this being accidentally
# used in production. We will generate credentials for test and development
# instead.
remove_file("config/master.key")
remove_file("config/credentials.yml.enc")
write_secret_key_base(create_secret, "development")
write_secret_key_base(create_secret, "test")
