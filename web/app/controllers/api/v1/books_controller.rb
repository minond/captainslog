class Api::V1::BooksController < ApiController
  # === URL
  #   GET /api/v1/books
  #
  # == Sample request
  #   /api/v1/books
  #
  def index
    render :json => current_user.books.to_json
  end
end
