require "test_helper"

class ExtractorTest < ActiveSupport::TestCase
  test "save happy path" do
    assert extractor.save
  end

private

  # @return [Extractor]
  def extractor
    user = create(:user)
    book = create(:book, :user => user)
    Extractor.new(:book => book,
                  :user => user,
                  :label => "a",
                  :match => "/b/",
                  :data_type => :number)
  end
end
