describe JobPresenter do
  subject { described_class.new(job) }

  let(:job) do
    create(:job, :kind => kind,
                 :status => status,
                 :connection => connection,
                 :started_at => started_at,
                 :stopped_at => stopped_at)
  end

  let(:connection) { create(:connection, :service => :fitbit) }
  let(:status) { :done }
  let(:kind) { :pull }
  let(:started_at) { 62.seconds.ago }
  let(:stopped_at) { 21.seconds.ago }

  describe "#run_time" do
    it { expect(subject.run_time).to eq "00:00:41" }

    context "when there is no run_time information" do
      let(:status) { :initiated }
      it { expect(subject.run_time).to eq "--:--:--" }
    end
  end

  describe "#kind" do
    context do
      let(:kind) { :pull }
      it { expect(subject.kind).to eq "Pull for Fitbit" }
    end

    context do
      let(:kind) { :backfill }
      it { expect(subject.kind).to eq "Backfill for Fitbit" }
    end

    context do
      let(:kind) { :testing }
      it { expect(subject.kind).to eq "Testing" }
    end
  end
end
