require 'digest/sha1'
require 'active_record'
$:.unshift File.dirname(__FILE__)


class User < ActiveRecord::Base

	#Relations
	has_many :uses
	has_many :apps, :through => :uses


	#Validators
	validates :login, :presence => true
	validates :password, :presence => true
	validates :login, :uniqueness => true
	validates :login, :format => { :with => /^[a-z0-9]{4,20}$/i, :on => :create }

	def password=(password)
		unless password.nil?
    		self[:password] = Digest::SHA1.hexdigest(password).inspect[1..40]
		end
  	end

  	def self.authenticate(login, password)
		user = User.find_by_login(login)
		!user.nil? && user.password == Digest::SHA1.hexdigest(password).inspect[1..40]
  	end 

	def self.delete_users(user_id)
		user = User.find_by_id(user_id)
		if !user.nil?	
    		user.delete
			user.save
			uses = Use.where(:user_id => user.id)
			uses.each do |u|
					u.delete
					u.save
			end
   	 	else
    		@error = true
		end		
	end
end
