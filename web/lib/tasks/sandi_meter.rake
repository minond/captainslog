# frozen_string_literal: true

task :sandi_meter => %i[sandi_meter:run]

namespace :sandi_meter do
  desc "Run rails best practices"

  task :run do
    puts "Running Sandi Meter"
    puts `sandi_meter -d`
  end
end
