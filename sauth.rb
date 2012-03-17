#encoding: UTF-8
require 'sinatra'
$: << File.dirname(__FILE__)
require 'spec/spec_helper'
enable :sessions

helpers do
	def current_user
		session[:current_user]
	end

	def disconnect
    	session[:current_user] = nil
		response.set_cookie("sauth", {:value => '', :expires => Time.at(0), :path => '/'})
  	end

	def connect(user)
		session[:current_user] = user.login
		response.set_cookie("sauth", {:value => user.login, :expires => Time.parse(Date.today.next_day(7).to_s), :path => '/'})
	end

	def connected?
		if session[:current_user]==nil && request.cookies["sauth"]!=nil
			user = User.find_by_login(request.cookies["sauth"])
			if user != nil
				connect(user)
			else
				disconnect
			end
		end
		!session[:current_user].nil?
	end
	
end

get '/' do
	if connected?
		if session[:current_user] == "admin"
			redirect '/sauth/admin'
		else
			redirect "/#{current_user}"
		end
	else
		erb :"sessions/new"
	end
end

get '/:current_user' do
	@user = session[:current_user]
	admin = App.find_by_admin(@user)
	if admin
		@app = true
		@app_name = admin.name
		@app_url = admin.url
	end
	erb :"users/profil"
end

get '/users/new' do
	erb :"users/new"
end

post '/users' do
	if connected?
		redirect '/'
	else
		user = User.new
		user.login = params[:login]
		user.password = params[:password]
		if user.valid? && params[:password] == params[:password_confirmation]
			user.save
			connect(user)
			redirect '/'
		else
			@error = true
			erb :"users/new"
		end
	end
end


get '/?:app_name?/sessions/new/?' do	
	if connected?
		if params['app_name']==nil
			redirect '/'
		else
			app = App.find_by_name(params['app'])
			use = Use.new
			use.app = app
			use.uer = current_user
			use.save
			redirect to(app.url+params['origin']+'?login='+current_user)
		end
	else
		erb :"sessions/new"
	end
end

post '/?:app_name?/sessions/?' do
	if connected?
		redirect '/'
	else
		user = User.find_by_login(params[:login])
		if User.authenticate(params[:login], params[:password])
			connect(user)
			redirect '/'
		else
			@error_informations = false
			@error_login_not_exists = false
			if user!=nil
				@error_informations = true
				erb :"sessions/new"
			else
				@error_login_not_exists = true
				erb :"sessions/new"
			end
		end
	end
end

get '/app/new' do
	if connected?
		erb :"app/new"
	else
		erb :"sessions/new"
	end
end

post '/app' do
	if connected?
		app = App.new
		app.name = params[:name]
		app.url = params[:url]
		app.admin = current_user
	
		if app.valid?
			app.save
			redirect '/'
		else
			@error_app = true
			erb :"app/new"
		end
	else
		redirect '/'
	end
end

get '/app/delete' do
	if connected?
		App.delete_apps(params["app"],current_user)
		redirect '/'
	else
		redirect '/'
	end
end

get '/sauth/admin' do
	if connected?
		if current_user == "admin"
			@user = current_user
			@list_user = User.all
			erb :"/sauth/admin"
		else
			redirect '/'
		end
	else
		redirect '/'
	end
end

get '/sauth/users/delete' do
	if connected?
		if current_user == "admin"
			User.delete_users(params["user"])
			redirect "/sauth/admin"
		else
			@error_admin = true
			redirect "/"
	  	end
	else
		@error_admin = true
		redirect "/"
	end
end

get '/sessions/disconnect' do
	disconnect
	redirect '/'
end



