describe Presenter do
  subject { create(:job) }

  describe "#presenter" do
    it { expect(subject.presenter).to be_a JobPresenter }
    it { expect(subject.presenter).to be subject.presenter }
  end
end
