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

    create_or_update_entries

    log.puts "done"
  end

  def create_or_update_entries
    proto_entries.each do |proto_entry|
      create_entry(proto_entry)
    rescue ActiveRecord::RecordInvalid
      update_entry(proto_entry)
    end
  end

  # @param [ProtoEntry]
  def create_entry(proto_entry)
    entry = book.new_entry(proto_entry.text, proto_entry.date, proto_entry.digest)
    entry.connection = connection
    entry.save!
    log.puts "creating new entry with digest #{proto_entry.digest}"
  end

  # @param [ProtoEntry]
  def update_entry(proto_entry)
    book.update_entry(proto_entry.digest, proto_entry.text)
    log.puts "updating existing entry with digest #{proto_entry.digest}"
  end

  # @return [Array<ProtoEntry>]
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
