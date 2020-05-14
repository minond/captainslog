class Job < ApplicationRecord
  belongs_to :user

  validates :args, :status, :kind, :user, :presence => true

  enum :status => %i[initiated running errored done]

  class InvalidKind < ArgumentError; end
  class InvalidArguments < ArgumentError; end

  # @return [Job]
  def self.schedule!(user, kind, args)
    arg_class = arg_class_for_kind(kind)

    raise InvalidKind, "invalid kind: #{kind}" unless arg_class
    raise InvalidArguments, "expected #{arg_class} for #{kind} job but got #{args.class}" unless args.is_a?(arg_class)

    create!(:user => user,
            :status => :initiated,
            :kind => kind,
            :args => Base64.encode64(YAML.dump(args)))
  end

  # @return [Class]
  def self.arg_class_for_kind(kind)
    "Execute#{kind.to_s.camelcase}Job::Arguments".safe_constantize
  end

  # @return [Class]
  def self.command_class_for_kind(kind)
    "Execute#{kind.to_s.camelcase}Job".safe_constantize
  end

  # @return [Object]
  def args
    arg_class = self.class.arg_class_for_kind(kind)
    YAML.safe_load(self[:args], [arg_class])
  end

  # @return [Class]
  def command
    self.class.command_class_for_kind(kind)
  end

  # @return [Float, nil]
  def run_time
    return nil if initiated? || started_at.nil?
    return DateTime.current - started_at.to_i if running?

    stopped_at - started_at
  end

  # @return [String]
  def run_time_s
    return "--:--:--" if run_time.nil?

    Time.at(run_time).utc.strftime("%H:%M:%S")
  end
end
