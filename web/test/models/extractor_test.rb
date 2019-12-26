require "test_helper"

class ExtractorTest < ActiveSupport::TestCase
  test "save happy path" do
    assert extractor.save
  end

private

  # @return [Extractor]
  def extractor
    Extractor.new(:book => create(:book),
                  :label => "a",
                  :match => "/b/",
                  :type => 1)
  end
end
