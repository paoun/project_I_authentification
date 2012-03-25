$: << File.dirname(__FILE__)

require 'sinatra'
set :port, 1990
set :secret, 'secret'

enable :sessions

helpers do
	def current_user
    	session["current_user_app"]
  	end
end

before '/protected' do
      redirect 'http://localhost:4567/appli1/sessions/new?origin=/protected' if !current_user && !params['secret']
end

get '/' do
	erb :"main_page"
end



get '/protected' do
  	if params[:secret]=settings.secret
		session[:current_user_app]=params["login"]
  	end

  	if !session[:current_user_app].nil? || !params["login"].nil? 
		erb :"protected"
  	else
		redirect "http://localhost:4567/appli1/sessions/new?origin=/protected"
  	end
end
