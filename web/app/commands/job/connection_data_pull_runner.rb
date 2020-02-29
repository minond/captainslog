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
    log.puts "pulling data for connection id #{args.connection_id}"
    pull.each do |item|
      log.puts "  - #{item}"
    end
  end

  # @return [Array<Object>]
  def pull
    connection.client.pull(:start_date => args.start_date,
                           :end_date => args.end_date)
  end

  # @return [Connection]
  def connection
    Connection.find(args.connection_id)
  end
end
