class User < ApplicationRecord
  # :confirmable, :lockable, :timeoutable, :trackable, :omniauthable,
  # :recoverable, :rememberable
  devise :database_authenticatable, :registerable

  has_many :connections, :dependent => :destroy

  validates :email, :presence => true, :uniqueness => true

  after_initialize :constructor

  # @return [String]
  def icon_url
    "https://www.gravatar.com/avatar/#{email_hash}?d=blank"
  end

  # @param [String] value
  # @return [String]
  def encrypt_value(value)
    encryptor.encrypt_and_sign(value)
  end

  # @param [String] value
  # @return [String]
  def decrypt_value(value)
    encryptor.decrypt_and_verify(value)
  end

private

  def constructor
    self.salt ||= SecureRandom.hex(ActiveSupport::MessageEncryptor.key_len)
  end

  # @return [String]
  def email_hash
    Digest::MD5.hexdigest(email.downcase)
  end

  # @return [String]
  def key
    len = ActiveSupport::MessageEncryptor.key_len
    secret = Rails.application.credentials.secret_key_base
    generator = ActiveSupport::KeyGenerator.new(secret)
    generator.generate_key(salt, len)
  end

  # @return [ActiveSupport::MessageEncryptor]
  def encryptor
    ActiveSupport::MessageEncryptor.new(key)
  end
end
