class User < ApplicationRecord
  # :confirmable, :lockable, :timeoutable, :trackable, :omniauthable,
  # :recoverable, :rememberable, :validatable
  devise :database_authenticatable, :registerable

  after_initialize :constructor

private

  def constructor
    self.salt ||= SecureRandom.hex(ActiveSupport::MessageEncryptor.key_len)
  end
end
