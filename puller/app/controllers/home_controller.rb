class HomeController < ApplicationController
  before_action :set_no_cache_headers

  def home
    if current_user
      component HomeComponent, :connections => connections,
                               :jobs => jobs
    else
      redirect_to :new_user_session
    end
  end

  # @return [Array<Connection>]
  def connections
    current_user.connections.order("service")
  end

  # @return [Array<Job>]
  def jobs
    current_user.jobs.order("created_at desc").first(100)
  end
end
