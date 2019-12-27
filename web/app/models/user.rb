class User < ApplicationRecord
  # :confirmable, :lockable, :timeoutable, :trackable, :omniauthable,
  # :registerable, :recoverable
  devise :database_authenticatable, :rememberable, :validatable

  has_many :books

  validates :email, :presence => true
end
