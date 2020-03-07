class Job < ApplicationRecord
  extend Registration

  belongs_to :user

  validates :args, :status, :kind, :user, :presence => true

  MAIN_KINDS = %i[connection_data_pull_standard connection_data_pull_backfill].freeze
  TEST_KINDS = %i[test_log test_error test_exception].freeze

  enum :kind => Rails.env.test? ? MAIN_KINDS + TEST_KINDS : MAIN_KINDS
  enum :status => %i[initiated running errored done]

  after_create :schedule_run

  register :connection_data_pull_backfill,
           Job::ConnectionDataPullBackfillArgs,
           Job::ConnectionDataPullRunner

  register :connection_data_pull_standard,
           Job::ConnectionDataPullStandardArgs,
           Job::ConnectionDataPullRunner

  class InvalidKind < ArgumentError; end
  class InvalidArguments < ArgumentError; end

  # @param [User] user
  # @param [Symbol] kind
  # @param [Job::Args] args
  # @return [Job]
  # @raise [ArgumentError] on invalid kind of argument class
  def self.schedule!(user, kind, args)
    arg_class, _runner = Job.lookup_registration(kind)
    raise InvalidKind, "invalid kind: #{kind}" unless arg_class
    raise InvalidArguments, "expected #{arg_class} for #{kind} job but got #{args.class}" unless args.is_a?(arg_class)

    create(:user => user,
           :status => :initiated,
           :kind => kind,
           :args => Base64.encode64(Marshal.dump(args)))
  end

  # @return [String] status
  def run!
    return status unless status.to_sym.in? %i[initiated errored]
    raise "invalid kind #{kind}" unless runner

    run

    status
  end

  # @return [Job::Args]
  def decoded_args
    # rubocop:disable Security/MarshalLoad
    Marshal.load(Base64.decode64(args))
    # rubocop:enable Security/MarshalLoad
  end

private

  def run
    running!

    cmd, err = safe_run
    capture_errors(cmd, err)

    update(:status => run_status(cmd, err),
           :logs => log.string)

    @log = nil
  end

  def schedule_run
    RunJob.perform_later self
  end

  # @return [Tuple<SimpleCommand, Error>]
  def safe_run
    [runner.call(decoded_args, log), nil]
  rescue StandardError => e
    [nil, e]
  end

  # @return [StringIO]
  def log
    @log ||=
      begin
        log = StringIO.new

        if logs.present?
          log.puts logs
          log.write("\n\n")
          log.puts "-----------------------------------------------"
        end

        log
      end
  end

  # @return [Class, nil]
  def runner
    _arg_class, runner = Job.lookup_registration(kind)
    runner
  end

  # @param [SimpleCommand] cmd
  # @param [Error] err
  # @return [Symbol]
  def run_status(cmd, err)
    err.nil? && cmd.errors.empty? ? :done : :errored
  end

  # @param [SimpleCommand, nil] cmd
  # @param [Error, nil] err
  # rubocop:disable Metrics/AbcSize
  def capture_errors(cmd, err)
    unless err.nil?
      log.puts "error: #{err.class}"
      log.puts "message: #{err.message}"
      log.puts err.backtrace.join("\n").indent(4)
    end

    cmd&.errors&.full_messages&.each do |msg|
      log.puts "error: #{msg}"
    end
  end
  # rubocop:enable Metrics/AbcSize
end
