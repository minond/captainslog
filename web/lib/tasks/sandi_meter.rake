# frozen_string_literal: true

task :sandi_meter => %i[sandi_meter:run]

namespace :sandi_meter do
  desc "Run rails best practices"

  task :run do
    puts "Running rails best practices!"
    bundle exec "sandi_meter"
  end
end
