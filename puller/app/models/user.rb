class User < ApplicationRecord
  # :confirmable, :lockable, :timeoutable, :trackable, :omniauthable,
  # :recoverable, :rememberable
  devise :database_authenticatable, :registerable

  has_many :connections

  validates :email, :presence => true, :uniqueness => true

  after_initialize :constructor

  # @return [String]
  def icon_url
    "https://www.gravatar.com/avatar/#{email_hash}?d=blank"
  end

private

  def constructor
    self.salt ||= SecureRandom.hex(ActiveSupport::MessageEncryptor.key_len)
  end

  # @return [String]
  def email_hash
    Digest::MD5.hexdigest(email.downcase)
  end
end
