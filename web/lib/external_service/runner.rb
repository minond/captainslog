module ExternalService
  class Runner
    # Initializes the child runner class and executes it.
    #
    # @param [Any] *args
    # @return [Any]
    def self.run(*args)
      new(*args).run
    end
  end
end
