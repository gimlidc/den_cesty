class Walker < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
		:recoverable, :rememberable, :trackable, :validatable, :token_authenticatable

	has_many :registration
	has_many :result
	has_many :report
	has_many :post

  # Setup accessible (or protected) attributes for your model	
  attr_accessible :email, :name, :surname, :year, :username, :password, :password_confirmation, :remember_me, :sex, :virtual, :phone

  # Extra validation
  validates :username, :surname, :year, :name, :email, :phone, :presence => true, :allow_blank => false
  validates :username, :email, :uniqueness => true
  validates :year, :format => {
    :with => /^[12][0-9]{3}$/
  }

  def nameSurname
    "#{name} #{surname}"
  end

  def nameSurnameYear
    "#{name} #{surname} (#{year})"
  end  

end
