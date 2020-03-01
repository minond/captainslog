class Job::ConnectionDataPullRunner
  prepend SimpleCommand

  # @param [Job::ConnectionDataPullArgs] args
  # @param [StringIO] log
  def initialize(args, log)
    @args = args
    @log = log
  end

private

  attr_reader :args
  attr_reader :log

  def call
    log.puts "pulling data for connection id #{connection.id}"
    log.puts "adding entries to book id #{book.id}"
    log.puts "creating #{proto_entries.size} new entries"

    create_entries

    log.puts "done"
  end

  def create_entries
    proto_entries.each do |proto_entry|
      book.add_entry(proto_entry.text, proto_entry.date)
    end
  end

  # @return [Array<Object>]
  def proto_entries
    @proto_entries ||= connection.client.pull(:start_date => args.start_date,
                                              :end_date => args.end_date)
  end

  # @return [Book]
  def book
    @book ||= connection.book
  end

  # @return [Connection]
  def connection
    @connection ||= Connection.find(args.connection_id)
  end
end
