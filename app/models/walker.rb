class Walker < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
	validate :username, :surname, :year, :name, :email, :presence => true
  attr_accessible :email, :name, :surname, :year, :username, :password, :password_confirmation, :remember_me
end
