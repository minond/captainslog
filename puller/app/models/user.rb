class User < ApplicationRecord
  include Encrypter

  # :confirmable, :lockable, :timeoutable, :trackable, :omniauthable,
  # :recoverable
  devise :database_authenticatable, :registerable, :rememberable

  has_many :connections, :dependent => :destroy
  has_many :jobs, :dependent => :destroy

  validates :email, :presence => true, :uniqueness => true

  after_initialize :constructor

private

  def constructor
    self.salt ||= generate_salt
  end
end
