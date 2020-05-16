describe ProcessJobJob do
  subject { described_class.new }

  let(:job) { create(:job, :kind => :test) }

  it "looks up the job and passes it to the command" do
    called = false
    command = proc { |_job| called = true }
    subject.perform(job.id, command)
    expect(called).to be true
  end
end
