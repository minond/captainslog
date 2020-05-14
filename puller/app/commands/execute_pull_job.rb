class ExecutePullJob
  prepend SimpleCommand

  class Arguments
    extend FastAttributes

    define_attributes :initialize => true, :attributes => true do
      attribute :connection_id, Integer
    end
  end

  def initialize(args, logs)
    @args = args
    @logs = logs
  end

  def call
  end

private

  attr_reader :args, :logs
end
