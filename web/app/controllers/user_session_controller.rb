class UserSessionController < ApplicationController
  around_action :user_timezone
end
