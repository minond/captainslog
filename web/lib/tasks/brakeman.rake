# frozen_string_literal: true

task :brakeman => %i[brakeman:run]

namespace :brakeman do
  desc "Check your code with Brakeman"

  task :run do
    require "brakeman"
    result = Brakeman.run :app_path => ".", :print_report => true, :pager => nil
    exit Brakeman::Warnings_Found_Exit_Code unless result.filtered_warnings.empty?
  end
end
