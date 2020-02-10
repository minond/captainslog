class SearchesController < ApplicationController
  # === URL
  #   GET /search
  #
  # === Request fields
  #   [String] query - search query string
  #
  # === Sample request
  #   /search?query=Running
  #
  def show
    locals :query => query,
           :results => results
  end

private

  # @return [Array<Entry>]
  def results
    Entry.by_user(current_user).by_text(query)
  end

  # @return [String]
  def query
    params[:query]
  end
end
