require "test_helper"

class ProcessorRunnerTest < ActiveSupport::TestCase
  test "it raises an error when there is a processing error" do
    response = ProcessorTest::HTTPResponse.new("400", "processing error")
    poster = ProcessorTest::Poster.new(response)
    client = Processor::Client.new(poster)
    runner = Processor::Runner.new(create(:entry), client)
    assert_raises(Processor::ProcessingError) { runner.process }
  end
end
