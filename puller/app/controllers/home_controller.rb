class HomeController < ApplicationController
  def home
    if current_user
      locals :connections => current_user.connections.order("service"),
             :jobs => current_user.jobs.order("created_at desc").first(100)
    else
      redirect_to :new_user_session
    end
  end
end
