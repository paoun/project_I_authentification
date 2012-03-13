require 'active_record'

class App < ActiveRecord::Base

	#Relations
	has_many :apps
	has_many :users, :through => :uses

	#Validators
	validates :name, :presence => true
	validates :url, :presence => true
	validates :admin, :presence => true
	validates :name, :uniqueness => true
	validates :url, :uniqueness => true
	validates :url, :format => { :with => /^https?:\/\/[a-z0-9._\/-]+/i, :on => :create }

	def self.get_apps(user_name) 
		App.find_all_by_user_id(User.find_by_login(username))
	end

	def self.delete_apps(app_id)
		app = App.find_by_id(app_id)
		if !app.nil?
			uses = Use.where(:app_id => app.id)
			uses.each do |u|
					u.delete
					u.save
			end
			app.delete
			app.save
		else
			@error_not_admin = true
		end
	end
end
