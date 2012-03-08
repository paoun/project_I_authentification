require 'sinatra'


$: << File.dirname(__FILE__)
require 'Spec/spec_helper'
helpers do
	def current_user
		session["current_user"]
	end

	def disconnect
    	session["current_user"] = nil
  	end
end

get '/' do
  	if current_user
    	"Bonjour #{current_user}"
  	else
    	'<a href="/sauth/appli_cliente_1/register">Login</a>'
 	 end
end

get '/sauth/appli_cliente_1/register' do
	msg_info = params[:info]
    erb :"sessions/register", :locals => {:info => msg_info}
end

post '/sauth/register' do
	user = User.new
	user.login = params[:login]
	user.password = params[:password]

	if user.login==nil or user.password==nil
		redirect '/sauth/appli_cliente_1/register?info=Missing_Login_Or_Password'
	else
		if user.valid?
			user.save
			redirect '/sauth/appli_cliente_1/new?info=Welcome_Now_You_Can_Connect'
		else
			u = User.find_by_login(user.login)
			if u!=nil
         		redirect '/sauth/appli_cliente_1/register?info=Login_Used' 
       		end
		end

	end	
end

get '/sauth/appli_cliente_1/new' do
	msg_info = params[:info]
	erb :"sessions/new", :locals => {:info => msg_info}
end

post '/sauth/sessions' do
	user = User.find_by_login(params[:login])
	if user!=nil and user.password == params[:password]
		redirect '/sauth/appli_cliente_1/protected'
	else
		if user!=nil and user.password != params[:password]
			redirect '/sauth/appli_cliente_1/new?info=Pass_Not_Valid'
		else
			if user == nil 
				redirect '/sauth/appli_cliente_1/new?info=Login_Not_Exist'
			end
		end
	end
end


#before '/appli_cliente_1/protected' do
#	redirect 'sauth/register?origine=/appli_cliente_1/protected' unless current_user
#end

#get '/appli_cliente_1/protected' do
#	erb :"appli_cliente_1/protected", :locals => {:user => current_user}
#end


