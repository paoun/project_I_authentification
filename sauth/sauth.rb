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

before '/' do
	redirect '/sessions/new' if !connected?
end


before '/app/new' do
	redirect '/sessions/new' if !connected?
end

before '/app' do
	redirect '/' if !connected?
end


before '/sauth/admin' do
	redirect '/' if !connected?
end


before '/app/delete' do
	redirect '/' if !connected?
end

get '/' do
	if session[:current_user] == "admin"
		redirect '/sauth/admin'
	else
			redirect "/#{current_user}"
	end
end

get '/:current_user' do
	@user = session[:current_user]
	admin = App.find_by_admin(@user)
	@apps = App.where(:admin => @user)
	@util = Use.where(:user_id => User.find_by_login(@user))
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
		if params['nameapp']==nil
			redirect '/'
		else
			app = App.find_by_name(params['nameapp'])
			user = session[:current_user]
			redirect_app = App.redirect(app,params['origin'],user)
			redirect redirect_app
		end
	else
		user = User.new(:login => params[:login],:password => params[:password])
		if user.valid? && params[:password] == params[:password_confirmation]
			user.save
			connect(user)
			if params['nameapp']==nil
				redirect '/'
			else
				app = App.find_by_name(params['nameapp'])
				redirect_app = App.redirect(app,params['origin'],user)
				redirect redirect_app
			end
		else
			@error = true
			erb :"users/new"
		end
	end
end

get '/sessions/new' do
	if connected?
		redirect '/'
	else
		erb :"sessions/new"
	end
end

post '/sessions' do
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

get '/:app_name/sessions/new' do

	if connected?
		app = App.find_by_name(params[:app_name])
		user = User.find_by_login(current_user)
		redirect App.redirect(app,params['origin'],user)
	else
		erb :"sessions/new"
	end
end

post '/:app_name/sessions' do
	if connected?
		app = App.find_by_name(params[:app_name])
		user = User.find_by_login(current_user)
		redirect App.redirect(app,params['origin'],user)
	else
			
		user = User.find_by_login(params[:login])
		if User.authenticate(params[:login], params[:password])
			connect(user)
			app = App.find_by_name(params[:app_name])
			redirect App.redirect(app,params['origin'],user)
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
		erb :"app/new"
end

post '/app' do
	app = App.new(:name => params[:name],:url=> params[:url],:admin=>current_user)
	if app.valid?
		app.save
		redirect '/'
	else
		@error_app = true
		erb :"app/new"
	end
end

get '/app/delete' do
	App.delete_apps(params["app"],current_user)
	redirect '/'
end

get '/sauth/admin' do
	if current_user == "admin"
		@user = current_user
		@list_user = User.all
		admin = App.find_by_admin(@user)
		@apps = App.where(:admin => @user)
		@util = Use.where(:user_id => User.find_by_login(@user))
		erb :"/sauth/admin"
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



