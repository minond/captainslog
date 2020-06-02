class HomeController < ApplicationController
  before_action :set_no_cache_headers

  # GET /
  def home
    if current_user
      component Welcome::Home, :connections => connections,
                               :jobs => jobs
    else
      redirect_to :new_user_session
    end
  end

private

  # @return [Array<Connection>]
  def connections
    current_user.connections.order("service")
  end

  # @return [Array<Job>]
  def jobs
    current_user.jobs.order("created_at desc").first(100)
  end
end
