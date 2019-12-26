require "test_helper"

class ProcessorRequestTest < ActiveSupport::TestCase
  test "#to_hash" do
    entry = build(:entry, :book_id => 42, :original_text => "hi there")
    expected = { :book_id => 42, :text => "hi there" }
    assert expected, Processor::Request.new(entry).to_hash
  end

  test "#to_json" do
    entry = build(:entry, :book_id => 42, :original_text => "hi there")
    expected = "{\"book_id\":42,\"text\":\"hi there\"}"
    assert expected, Processor::Request.new(entry).to_json
  end
end
