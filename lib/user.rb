require 'active_record'

class User < ActiveRecord::Base

	#Relations
	has_many :uses
	has_many :apps, :through => :uses


	#Validators
	validates :login, :presence => true
	validates :password, :presence => true
	validates :login, :uniqueness => true

end
