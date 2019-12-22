# frozen_string_literal: true

task :rails_best_practices => %i[rails_best_practices:run]

namespace :rails_best_practices do
  desc "Run rails best practices"

  task :run do
    puts "Running rails best practices!"
    puts `rails_best_practices`
  end
end
