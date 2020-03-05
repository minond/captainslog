ENV["RAILS_ENV"] ||= "test"

require "simplecov"

SimpleCov.start "rails" do
  add_group "Commands", "app/commands"
end

require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"

require_relative "./external_service_test_helper"
require_relative "./processor_test_helper"
require_relative "./querier_test_helper"

Rails.application.credentials.secret_key_base = "1" * 32

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def user(*attrs)
    @user ||= create(:user, *attrs)
  end

  def book(*attrs)
    @book ||= create(:book, { :user => user }.merge(*attrs))
  end
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  parallelize(:workers => :number_of_processors)

  parallelize_setup do |worker|
    SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
  end

  parallelize_teardown do
    SimpleCov.result
  end
end
