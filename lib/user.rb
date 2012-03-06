$:.unshift File.dirname(__FILE__)
#require 'active_record'
require 'password'

class User < ActiveRecord::Base

	include Password

	#Relations
	has_many :uses
	has_many :apps, :through => :uses


	#Validators
	validates :login, :presence => true
	validates :password, :presence => true
	validates :login, :uniqueness => true

end
