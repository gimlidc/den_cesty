class Walker < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, #:confirmable,
		:recoverable, :rememberable, :trackable, :validatable, :token_authenticatable

	has_many :registration
	has_many :result
	has_many :report
	has_many :post

  # Setup accessible (or protected) attributes for your model
	validate :username, :surname, :year, :name, :email, :presence => true
  attr_accessible :email, :name, :surname, :year, :username, :password, :password_confirmation, :remember_me, :sex

end
