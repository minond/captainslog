class Job < ApplicationRecord
  extend Registration
  include Instrumented

  traced :run, :tick

  belongs_to :user

  validates :args, :status, :kind, :user, :presence => true

  MAIN_KINDS = %i[
    connection_data_pull_standard
    connection_data_pull_backfill
    connection_data_pull_manual
  ].freeze

  TEST_KINDS = %i[
    test_log
    test_error
    test_exception
  ].freeze

  enum :kind => Rails.env.test? ? MAIN_KINDS + TEST_KINDS : MAIN_KINDS
  enum :status => %i[initiated running errored done]

  after_create :schedule_run

  register :connection_data_pull_backfill,
           Job::ConnectionDataPullBackfillArgs,
           Job::ConnectionDataPullRunner

  register :connection_data_pull_standard,
           Job::ConnectionDataPullStandardArgs,
           Job::ConnectionDataPullRunner

  register :connection_data_pull_manual,
           Job::ConnectionDataPullManualArgs,
           Job::ConnectionDataPullRunner

  default_scope { order(:created_at => :desc) }

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

    span = OpenTracing.active_span

    task_runner = Concurrent::Future.execute do
      with_active_span(span) { runner.call(decoded_args, log) }
    end

    tick_runner = Concurrent::TimerTask.execute(:execution_interval => 1.second) do
      with_active_span(span) { tick }
    end

    value = task_runner.value
    error = task_runner.reason
    tick_runner.kill

    capture_results(value, error)
  end

  # @param [SimpleCommand, nil] cmd
  # @param [Error, nil] err
  def capture_results(cmd, err)
    capture_errors(cmd, err)
    update(:status => run_status(cmd, err), :logs => log.string)
  end

  def schedule_run
    RunJob.perform_later self
  end

  # @return [StringIO]
  def log
    @log ||= StringIO.new
  end

  def tick
    update(:logs => log.string)
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
  # @return [Boolean]
  def errors?(cmd, err)
    return true if err.present?
    return true unless cmd&.errors&.full_messages&.empty?

    false
  end

  # @param [SimpleCommand, nil] cmd
  # @param [Error, nil] err
  def capture_errors(cmd, err)
    span = ::OpenTracing.active_span
    span&.set_tag("error", true) if errors?(cmd, err)

    log_command_errors(cmd, span)
    log_command_exception(err, span)
  end

  # @param [SimpleCommand, nil] cmd
  # @param [OpenTracing::Span, nil] span
  def log_command_errors(cmd, span)
    return if cmd.nil?
    return if cmd.errors.empty?

    cmd.errors.each do |key, msg|
      span&.log_kv(key => msg)
      log.puts "error: #{key}: #{msg}"
    end
  end

  # @param [Error, nil] err
  # @param [OpenTracing::Span, nil] span
  def log_command_exception(err, span)
    return if err.nil?

    log.puts "error: #{err.class}"
    log.puts "message: #{err.message}"
    span&.log_kv(:"error.kind" => err.class.to_s,
                 :"error.object" => err,
                 :message => err.message,
                 :stack => err.backtrace.join("\n"))
  end
end
