class SearchesController < ApplicationController
  before_action :require_login

  def show
    locals :books => books,
           :query => query,
           :results => results
  end

private

  # @return [Array<Entry>]
  def results
    Entry.by_user(current_user).by_text(query)
  end

  def query
    params[:query]
  end

  # @return [Array<Book>]
  def books
    @books ||= current_user.books
  end
end
