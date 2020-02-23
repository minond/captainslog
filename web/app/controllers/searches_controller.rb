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
    if query_long_enough?
      locals :query => query, :results => results
    else
      flash.alert = t(:query_not_long_enough)
      locals :query => query, :results => []
    end
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

  # @return [Boolean]
  def query_long_enough?
    query.present? && query.size >= 3
  end
end
