require "test_helper"

class ExtractorTest < ActiveSupport::TestCase
  test "save happy path" do
    assert extractor.save
  end

private

  # @return [Extractor]
  def extractor
    Extractor.new(:book => create(:book),
                  :user => create(:user),
                  :label => "a",
                  :match => "/b/",
                  :type => 1)
  end
end
