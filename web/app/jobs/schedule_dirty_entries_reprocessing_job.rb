class ScheduleDirtyEntriesReprocessingJob < ApplicationJob
  queue_as :default

  # @param [Book] book
  def perform(book)
    book.dirty_entries.find_in_batches do |entries|
      entries.each(&:schedule_processing)
    end
  end
end
