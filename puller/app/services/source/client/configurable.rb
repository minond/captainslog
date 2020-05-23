module Source::Client::Configurable
  extend extend ActiveSupport::Concern

  class_methods do
    # @param [Symbol] name
    def config_from(name)
      @config_name = name
    end

    def config_name
      @config_name
    end
  end

  # @return [Hash]
  def config(options = {})
    options.merge(::Rails.application.config.send(self.class.config_name)).with_indifferent_access
  end
end
