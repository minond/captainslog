class Job::ConnectionDataPullRunner < Job::Runner
  prepend SimpleCommand

  def call
    print_job_information
    create_or_update_entries
    update_connection_credentials
    log.puts "done"
  end

private

  def print_job_information
    log.puts "pulling data for connection id #{connection.id}"
    log.puts "adding entries to book id #{book.id}"
    log.puts "creating #{proto_entries.size} new entries"
  end

  def create_or_update_entries
    proto_entries.each do |proto_entry|
      log.write "handling entry with digest #{proto_entry.digest.strip} ... "
      create_entry(proto_entry)
    rescue ActiveRecord::RecordInvalid
      update_entry(proto_entry)
    end
  end

  def update_connection_credentials
    log.puts "updating connection credentials"
    UpdateConnectionCredentials.call(connection)
  end

  # @param [ProtoEntry]
  def create_entry(proto_entry)
    entry = book.new_entry(proto_entry.text, proto_entry.date, proto_entry.digest)
    entry.connection = connection
    entry.save!
    log.puts "created"
  end

  # @param [ProtoEntry]
  def update_entry(proto_entry)
    book.update_entry(proto_entry.digest, proto_entry.text)
    log.puts "updated"
  end

  # @return [Array<ProtoEntry>]
  def proto_entries
    @proto_entries ||=
      if args.is_a?(Job::ConnectionDataPullBackfillArgs)
        connection.client.data_pull_backfill
      else
        connection.client.data_pull_standard
      end
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
