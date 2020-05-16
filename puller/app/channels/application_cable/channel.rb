module ApplicationCable
  class Channel < ActionCable::Channel::Base
    def render(partial, locals = {})
      ApplicationController.render(:partial => partial,
                                   :locals => locals)
    end
  end
end
