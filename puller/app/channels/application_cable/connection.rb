module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = load_user
    end

  private

    def load_user
      env["warden"].user || reject_unauthorized_connection
    end
  end
end
