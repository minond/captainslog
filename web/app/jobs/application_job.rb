class ApplicationJob < ActiveJob::Base
  queue_as :default
  retry_on ActiveRecord::Deadlocked
  discard_on ActiveJob::DeserializationError
end
