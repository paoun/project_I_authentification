#encoding: UTF-8
require 'sinatra'
$: << File.dirname(__FILE__)
require 'Spec/spec_helper'
enable :sessions

helpers do
	def current_user
		session[:current_user]
	end

	def disconnect
    	session[:current_user] = nil
  	end
end

get '/' do
  	if current_user!=nil
    	#"Bonjour #{current_user}"
		redirect "/#{current_user}"
  	else
    	erb :"sessions/register"
 	end
end

get '/:current_user' do
	@user = session[:current_user]
	admin = App.find_by_admin(@user)
	#permet de lister les applications dont l'utilisateur est admin
	if admin
		@app = true
		@app_name = admin.name
		@app_url = admin.url
	end
	erb :"sessions/profil"
end

get '/sauth/sessions/new' do
	erb :"sessions/new"
end

post '/sauth/sessions/new' do

	#Cas où l'utilisateur est déjà connecté
	if current_user
		redirect '/'
	else
		user = User.new
		user.login = params[:login]
		user.password = params[:password]
		#Cas où tout se passe bien
		if user.valid? && params[:password] == params[:password_confirmation]
			user.save
			session[:current_user] = user.login
			redirect '/'
		else
			#Cas où un problème survient dans la saisie du mot de passe ou du login
			@error = true
			erb :"sessions/new"
		end
	end
end


get '/sauth/sessions/register' do	
	erb :"sessions/register"
end

post '/sauth/sessions/register' do
	#Cas où l'utilisateur est déjà connecté
	if current_user
		redirect '/'
	else
		#Cas où tout se passe bien
		user = User.find_by_login(params[:login])
		if User.authenticate(params[:login], params[:password])
			session[:current_user] = user.login
			redirect '/'
		else
			@error_informations = false
			@error_login_not_exists = false
			if user!=nil
				@error_informations = true
				erb :"sessions/register"
			else
				
				@error_login_not_exists = true
				erb :"sessions/register"
			end
		end
	end
end

#Sauth concernant les applications
get '/sauth/app/new' do
	if current_user
		erb :"app/new"
	else
		erb :"sessions/register"
	end
end

post '/sauth/app/new' do
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

get '/?:app_name?/sessions/register/?' do

	if current_user
	
	end

end

post '/?:app_name?/sessions/register/?' do
end

get '/sauth/sessions/disconnect' do
	disconnect
	redirect '/'
end

before '/appli_cliente_1/protected' do
	redirect 'sauth/register?origine=/appli_cliente_1/protected' unless current_user
end

get '/appli_cliente_1/protected' do
	erb :"appli_cliente_1/protected", :locals => {:user => current_user}
end


