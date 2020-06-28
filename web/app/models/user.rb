class User < ApplicationRecord
  # :confirmable, :lockable, :timeoutable, :trackable, :omniauthable,
  # :registerable, :recoverable
  devise :database_authenticatable, :rememberable, :validatable

  has_many :books, :dependent => :destroy
  has_many :entries
  has_many :reports, :dependent => :destroy

  after_initialize :constructor

  validates :email, :presence => true, :uniqueness => true

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

  # Used to build the user's homepage dropdown field.
  #
  # @return <Tuple<String, String>>
  def homepage_options
    homepage_report_options + homepage_book_options
  end

  # @return [String]
  def jwt
    JWT.encode_application_token(:user_id => id)
  end

private

  def constructor
    self.salt ||= SecureRandom.hex(ActiveSupport::MessageEncryptor.key_len)
  end

  # Used to build the user's homepage options.
  #
  # @return <Tuple<String, String>>
  def homepage_book_options
    books.map do |book|
      [book.name, Rails.application.routes.url_helpers.book_path(book)]
    end
  end

  # Used to build the user's homepage options.
  #
  # @return <Tuple<String, String>>
  def homepage_report_options
    reports.map do |report|
      [report.label, Rails.application.routes.url_helpers.report_path(report)]
    end
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
