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

  # rubocop:disable Metrics/AbcSize
  def create_or_update_entries
    proto_entries.each do |proto_entry|
      book.new_entry(proto_entry.text, proto_entry.date, proto_entry.digest).save!
      log.puts "creating new entry with digest #{proto_entry.digest}"
    rescue ActiveRecord::RecordInvalid
      book.update_entry(proto_entry.digest, proto_entry.text)
      log.puts "updating existing entry with digest #{proto_entry.digest}"
    end
  end
  # rubocop:enable Metrics/AbcSize

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
