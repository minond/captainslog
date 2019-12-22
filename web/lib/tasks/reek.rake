# frozen_string_literal: true

task :reek => %i[reek:run]

namespace :reek do
  desc "Run reek"

  task :run do
    puts "Running reek!"
    bundle exec "reek ."
  end
end
