require 'active_record'

class App < ActiveRecord::Base

	#Relations
	has_many :apps
	has_many :users, :through => :uses

	#Validators
	validates :name, :presence => true
	validates :url, :presence => true
	validates :name, :uniqueness => true
	validates :url, :uniqueness => true

end
