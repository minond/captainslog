describe URN do
  describe "#to_s" do
    it { expect(described_class.new(:captainslog, 4).to_s).to eq "urn:captainslog:4" }
    it { expect(described_class.new(:captainslog, 4, :r => {}, :q => {}, :f => nil).to_s).to eq "urn:captainslog:4" }
    it { expect(described_class.new(:captainslog, 4, :r => { :name => nil }, :q => { :label => nil }, :f => nil).to_s).to eq "urn:captainslog:4" }
    it { expect(described_class.new(:captainslog, 4, :r => { :name => "Marcos", :age => 42 }, :q => { :label => nil }, :f => nil).to_s).to eq "urn:captainslog:4?=name=Marcos&age=42" }
    it { expect(described_class.new(:captainslog, 4, :r => { :name => "Marcos", :age => 42 }, :q => { :label => "Workouts", :blah => "yes" }, :f => nil).to_s).to eq "urn:captainslog:4?=name=Marcos&age=42?+label=Workouts&blah=yes" }
    it { expect(described_class.new(:captainslog, 4, :r => { :name => "Marcos", :age => 42 }, :q => { :label => "Workouts", :blah => "yes" }, :f => "main").to_s).to eq "urn:captainslog:4?=name=Marcos&age=42?+label=Workouts&blah=yes#main" }
    it { expect(described_class.new(:captainslog, 4, :r => {}, :q => { :label => "Workouts", :blah => "yes" }, :f => "main").to_s).to eq "urn:captainslog:4?+label=Workouts&blah=yes#main" }
    it { expect(described_class.new(:captainslog, 4, :r => {}, :q => {}, :f => "main").to_s).to eq "urn:captainslog:4#main" }
  end

  describe ".parse" do
    let(:parsed) { described_class.parse(str) }

    context "no components" do
      let(:str) { "urn:n1:n2" }

      it { expect(parsed.nid).to eq "n1" }
      it { expect(parsed.nss).to eq "n2" }
      it { expect(parsed.r).to be_empty }
      it { expect(parsed.q).to be_empty }
      it { expect(parsed.f).to be_nil }
    end

    context "with r component" do
      let(:str) { "urn:n1:n2?=age=42&name=Marcos" }

      it { expect(parsed.nid).to eq "n1" }
      it { expect(parsed.nss).to eq "n2" }
      it { expect(parsed.r).to include(:age => "42", :name => "Marcos") }
      it { expect(parsed.q).to be_empty }
      it { expect(parsed.f).to be_nil }
    end

    context "with q component" do
      let(:str) { "urn:n1:n2?+label=steps&service=fitbit" }

      it { expect(parsed.nid).to eq "n1" }
      it { expect(parsed.nss).to eq "n2" }
      it { expect(parsed.r).to be_empty }
      it { expect(parsed.q).to include(:label => "steps", :service => "fitbit") }
      it { expect(parsed.f).to be_nil }
    end

    context "with f component" do
      let(:str) { "urn:n1:n2#main" }

      it { expect(parsed.nid).to eq "n1" }
      it { expect(parsed.nss).to eq "n2" }
      it { expect(parsed.r).to be_empty }
      it { expect(parsed.q).to be_empty }
      it { expect(parsed.f).to eq "main" }
    end

    context "with r and q components" do
      let(:str) { "urn:n1:n2?=age=42&name=Marcos?+label=steps&service=fitbit" }

      it { expect(parsed.nid).to eq "n1" }
      it { expect(parsed.nss).to eq "n2" }
      it { expect(parsed.r).to include(:age => "42", :name => "Marcos") }
      it { expect(parsed.q).to include(:label => "steps", :service => "fitbit") }
      it { expect(parsed.f).to be_nil }
    end

    context "with r and f components" do
      let(:str) { "urn:n1:n2?=age=42&name=Marcos#main" }

      it { expect(parsed.nid).to eq "n1" }
      it { expect(parsed.nss).to eq "n2" }
      it { expect(parsed.r).to include(:age => "42", :name => "Marcos") }
      it { expect(parsed.q).to be_empty }
      it { expect(parsed.f).to eq "main" }
    end

    context "with r, q, and f components" do
      let(:str) { "urn:n1:n2?=age=42&name=Marcos?+label=steps&service=fitbit#main" }

      it { expect(parsed.nid).to eq "n1" }
      it { expect(parsed.nss).to eq "n2" }
      it { expect(parsed.r).to include(:age => "42", :name => "Marcos") }
      it { expect(parsed.q).to include(:label => "steps", :service => "fitbit") }
      it { expect(parsed.f).to eq "main" }
    end
  end
end
