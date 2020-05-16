describe Job do
  describe "#run_time" do
    before { travel_to "1989-05-21 11:32:41".to_datetime }

    it { expect(build(:job).run_time).to be_nil }
    it { expect(build(:job, :running, :started_at => 67.seconds.ago).run_time.to_i).to eq 67 }
    it { expect(build(:job, :done, :started_at => 67.seconds.ago, :stopped_at => 51.seconds.from_now).run_time.to_i).to eq 118 }
  end
end
