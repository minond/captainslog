describe User do
  subject { User.new(:email => email) }

  let(:email) { "test@test.com" }
  let(:email_hash) { "b642b4217b34b1e8d3bd915fc65c4452" }

  describe "defaults" do
    it { expect(User.new).not_to be_nil }
  end

  describe "#encrypt" do
    it "is able to encrypt a value" do
      expect(subject.encrypt("123")).not_to be_nil
    end
  end

  describe "#decrypt" do
    let(:original) { "123" }
    let(:encrypted) { subject.encrypt(original) }
    let(:decrypted) { subject.decrypt(encrypted) }

    it "is able to decrypt and encrypted value" do
      expect(decrypted).to eq original
    end
  end
end
