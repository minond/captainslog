class Job::ConnectionDataPullManualArgs < Job::Args
  define_attributes :initialize => true, :attributes => true do
    attribute :connection_id, Integer
  end
end
