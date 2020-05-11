describe User do
  subject { User.new(:email => email) }

  let(:email) { "test@test.com" }
  let(:email_hash) { "b642b4217b34b1e8d3bd915fc65c4452" }

  describe "defaults" do
    it { expect(User.new).not_to be_nil }
  end

  describe "#icon_url" do
    it { expect(subject.icon_url).to include email_hash }
  end

  describe "#encrypt_value" do
    it "is able to encrypt a value" do
      expect(subject.encrypt_value("123")).not_to be_nil
    end
  end

  describe "#decrypt_value" do
    let(:original) { "123" }
    let(:encrypted) { subject.encrypt_value(original) }
    let(:decrypted) { subject.decrypt_value(encrypted) }

    it "is able to decrypt and encrypted value" do
      expect(decrypted).to eq original
    end
  end
end
