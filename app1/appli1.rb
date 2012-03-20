$: << File.dirname(__FILE__)

require 'sinatra'
set :port, 1990
set :secret, 'secret'

enable :sessions

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
