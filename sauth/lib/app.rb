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

	def self.exist?(app_name)
		!App.find_by_name(app_name).nil?
	end

	def self.get_apps(user_name) 
		App.find_all_by_user_id(User.find_by_login(username))
	end

	def self.delete_apps(app_id,user)
		app = App.find_by_id(app_id)
		if !app.nil?
			if user == app.admin
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
		else
			@error_not_admin = true
		end
	end

	def self.redirect(app, origin, user)
		if app.nil?
			redirect = '/'
		else
			use = Use.new
			use.app = app
			use.user = user
			use.save
			redirect = app.url+origin+'?login='+user.login
		end
		redirect
	end

end
