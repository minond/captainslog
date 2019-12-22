class BookController < ApplicationController
  around_action :use_timezone, :if => :current_user

  # === URL
  #   GET /book/:id
  #
  # === Request fields
  #   [Integer] id - the book id for the book to load
  #
  # === Sample request
  #   /book/1
  #
  def show
    @books = current_user.books
    @book = current_book
    @entries = current_entries

    @log_time = log_time

    @curr_time = Time.current
    @prev_time, @next_time = @book.grouping_prev_next_times(log_time)
  end

  # === URL
  #   POST /book/:id/entry
  #
  # === Request fields
  #   [Integer] id - the book id for the book to add the entry to
  #   [String] text - entry's original text
  #
  # === Sample request
  #   /book/1/entry?text=abc123
  #
  # === Sample response (HTML)
  #   Redirect to /book/1
  #
  def entry
    current_book.add_entry(params[:text], log_time.utc)
    redirect_to book_at_path(current_book, log_time.to_i)
  end

private

  # @return [Book]
  def current_book
    @current_book ||= current_user.books.find(current_book_id)
  end

  # @return [Integer]
  def current_book_id
    params[:id] || params[:book_id]
  end

  # @return [Array<Entry>]
  def current_entries
    collection = current_book.collection(log_time)
    collection.present? ? collection.entries : []
  end

  # Ensures controller methods use the user's selected timezone
  #
  # @return [Block] &block
  def use_timezone(&block)
    Time.use_zone(current_user.timezone, &block)
  end

  # @return [Time]
  def log_time
    log_time = params[:log_time]
    log_time.present? && log_time != "0" ? Time.at(log_time.to_i) : Time.current
  end
end
