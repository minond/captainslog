module Performer
  extend ActiveSupport::Concern

  class_methods do
    # Defines a perform_X_later method. Given a `NameOfJob` class, this method
    # will define `perform_name_of_later`.
    #
    # @example `performs ProcessJobJob`
    #
    #   def perform_process_job_later
    #     ProcessJobJob.perform_later(id)
    #   end
    #
    #
    # @param [Class] klass, should extend `ActiveJob::Base`
    def performs(klass)
      define_method "perform_#{klass.name.to_s.underscore[0...-4]}_later" do
        klass.perform_later(id)
      end
    end
  end
end
