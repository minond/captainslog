module Presenter
  include ActiveSupport::Concern

  def presenter
    @presenter ||= "#{self.class.name}Presenter".safe_constantize.new(self)
  end
end
