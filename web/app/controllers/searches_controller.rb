class SearchesController < ApplicationController
  before_action :require_login

  def show
    locals :query => query,
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
end
