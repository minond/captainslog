class User < ApplicationRecord
  # :confirmable, :lockable, :timeoutable, :trackable, :omniauthable,
  # :registerable, :recoverable
  devise :database_authenticatable, :rememberable, :validatable

  has_many :books

  validates :email, :presence => true, :uniqueness => true

  def icon_url
    "https://www.gravatar.com/avatar/#{email_hash}?d=blank"
  end

private

  def email_hash
    Digest::MD5.hexdigest(email.downcase)
  end
end
