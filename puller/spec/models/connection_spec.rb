describe Connection do
  subject { described_class.create_with_credentials(connection_attrs, credentials_hash) }

  let(:connection_attrs) do
    {
      :service => :lastfm,
      :user => create(:user)
    }
  end

  let(:credentials_hash) do
    {
      :user => :minond
    }
  end

  describe ".in_need_of_pull" do
    context "when there are no connections that need to be updated" do
      before { create_list(:connection, 3, :last_updated_at => 5.minutes.ago) }

      it "returns nothing" do
        expect(described_class.in_need_of_pull).to be_empty
      end
    end

    context "when there are connections that need to be updated" do
      before do
        create_list(:connection, 3, :last_updated_at => 5.minutes.ago)
        create_list(:connection, 2, :last_updated_at => 7.hours.ago)
      end

      it "returns nothing" do
        expect(described_class.in_need_of_pull.count).to eq 2
      end
    end
  end

  describe ".create_with_credentials" do
    it "creates the credentials" do
      expect { subject }.to change { Connection.count }.by 1
    end

    it "creates the credentials" do
      expect { subject }.to change { Credential.count }.by 1
    end
  end

  describe "#client" do
    it "returns the expected client class" do
      expect(subject.client).to be_a Service::Lastfm
    end

    it "authenticates the client with the latests credentials" do
      expect(subject.client.credential_options).to include credentials_hash
    end
  end

  describe "#schedule_backfill" do
    it "creates a job" do
      subject
      expect { subject.schedule_backfill }.to change { Job.count }.by 1
    end
  end

  describe "#schedule_pull" do
    it "creates a job" do
      subject
      expect { subject.schedule_pull }.to change { Job.count }.by 1
    end
  end

  describe "#recent_stats" do
    before do
      create(:job, :initiated, :connection => subject)
      create(:job, :done, :connection => subject)
      create(:job, :done, :connection => subject)
      create(:job, :errored, :connection => subject)
      create(:job, :running, :connection => subject)
    end

    let(:recent_stats) { subject.recent_stats }
    let(:recent_stats_statuses) { recent_stats.map(&:second) }

    it "returns recent job information" do
      expect(recent_stats_statuses).to match_array %w[done done errored running initiated]
    end
  end
end
