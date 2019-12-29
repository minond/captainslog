class User < ApplicationRecord
  # :confirmable, :lockable, :timeoutable, :trackable, :omniauthable,
  # :registerable, :recoverable
  devise :database_authenticatable, :rememberable, :validatable

  has_many :books

  validates :email, :presence => true, :uniqueness => true

  # @return [String, nil]
  def display_name
    name || email
  end

  # @return [String, nil]
  def display_character
    display_name[0]
  end
end
