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
end

get '/' do
  	if current_user!=nil
		if current_user == "admin"
			redirect '/sauth/admin'
		else
			redirect "/#{current_user}"
		end
  	else
		if request.cookies["sauth"]!=nil
			user = User.find_by_login(request.cookies["sauth"])
			session[:current_user]=user.login
			redirect "/#{current_user}"
		else
    		erb :"sessions/new"
		end
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
	if current_user
		redirect '/'
	else
		user = User.new
		user.login = params[:login]
		user.password = params[:password]
		if user.valid? && params[:password] == params[:password_confirmation]
			user.save
			session[:current_user] = user.login
			response.set_cookie("sauth", {:value => user.login, :expires => Time.parse(Date.today.next_day(7).to_s), :path => '/'})
			redirect '/'
		else
			@error = true
			erb :"users/new"
		end
	end
end


get '/sessions/new' do	
	erb :"sessions/new"
end

post '/sessions' do
	if current_user
		redirect '/'
	else
		user = User.find_by_login(params[:login])
		if User.authenticate(params[:login], params[:password])
			session[:current_user] = user.login
			response.set_cookie("sauth", {:value => user.login, :expires => Time.parse(Date.today.next_day(7).to_s), :path => '/'})
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
	if current_user
		erb :"app/new"
	else
		erb :"sessions/new"
	end
end

post '/app' do
	if current_user
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
	if current_user
		App.delete_apps(params["app"],current_user)
		redirect '/'
	else
		redirect '/'
	end
end

get '/sauth/admin' do
	if current_user
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
	if session["current_user"] == "admin"
		User.delete_users(params["user"])
    	redirect "/sauth/admin"
    else
    	@error_admin = true
    	redirect "/"
  	end
end

get '/:app/sessions/new' do
end

post '/:app/sessions' do
end

get '/sessions/disconnect' do
	disconnect
	redirect '/'
end



