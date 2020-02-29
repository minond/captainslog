module BookProcessingScheduling
private

  # Reprocess all of the book's entries to take into account this recent
  # change.
  def schedule_book_reprocessing
    book.schedule_processing
  end
end
