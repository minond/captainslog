describe Connection do
  subject { described_class.create_with_credentials(connection_attrs, credentials_hash) }

  let(:connection_attrs) do
    {
      :source => :lastfm,
      :user => create(:user)
    }
  end

  let(:credentials_hash) do
    {
      :user => :minond
    }
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
      expect(subject.client).to be_a Source::Lastfm
    end

    it "authenticates the client with the latests credentials" do
      expect(subject.client.credential_options).to include credentials_hash
    end
  end
end
