class UserController < ApplicationController
  def edit
    locals :user => current_user,
           :books => books
  end
end
