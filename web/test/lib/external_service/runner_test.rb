require "test_helper"

class ExternalServiceRunnerTest < ActiveSupport::TestCase
  test ".run" do
    assert_not ExternalServiceTestHelper::DummyRunner.ran
    ExternalServiceTestHelper::DummyRunner.run(nil)
    assert ExternalServiceTestHelper::DummyRunner.ran
  end

  test "missing request method" do
    runner = ExternalServiceTestHelper::DummyRunner.new(nil)
    assert_raises(NotImplementedError) { runner.response }
  end
end
