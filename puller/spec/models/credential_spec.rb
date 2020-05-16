describe Credential do
  subject { Credential.create_with_options(connection, options) }

  let(:user) { create(:user) }
  let(:connection) { create(:connection, :user => user) }

  let(:options) do
    {
      :name => "Marcos",
      :key => "hihihihi"
    }
  end

  describe ".create_with_options" do
    let(:original_values) { options.values }
    let(:stored_values) { subject.credential_options.map(&:value) }
    let(:decrypted_values) { subject.credential_options.map(&:decrypted_value) }

    it "creates the base credential record" do
      expect(subject).to be_a Credential
    end

    it "assigns the credential record to the user and connection" do
      expect(subject.user_id).to be user.id
      expect(subject.connection_id).to be connection.id
    end

    it "creates a credential option record for each key/value pair" do
      expect { subject }.to change { CredentialOption.count }.by options.keys.size
    end

    it "encrypts the values" do
      expect(stored_values).not_to include original_values
    end

    it "is able to decrypts values" do
      expect(decrypted_values).to eq original_values
    end
  end

  describe "#options" do
    it "returns decrypted options" do
      expect(subject.options).to include options
    end
  end
end
