class PullerController < ApplicationController
  PULLERS = [
    {
      :logo => "fitbit-logo.png",
      :redirect => "/puller/fitbit",
      :description => I18n.t(:fitbit_puller_description),
    },
  ].freeze

  # === URL
  #   GET /puller/new
  #
  # === Sample request
  #   /puller/new
  #
  def new
    locals :pullers => PULLERS
  end

  # === URL
  #   GET /puller/fitbit
  #
  # === Sample request
  #   /puller/fitbit
  #
  def fitbit
    redirect_to Puller::Fitbit.new.auth_url
  end
end
