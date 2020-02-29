class Job::ConnectionDataPullArgs < Job::Args
  define_attributes :initialize => true, :attributes => true do
    attribute :connection_id, Integer
    attribute :start_date, Date
    attribute :end_date, Date
  end
end
