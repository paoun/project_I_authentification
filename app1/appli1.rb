$: << File.dirname(__FILE__)

require 'sinatra'
set :port, 1990
helpers do 
  def current_user
    session["current_user"]
  end

  def disconnect
    session["current_user"] = nil
  end
end

enable :sessions

get '/' do
	erb :"main_page"
end



get '/protected' do
  if !session[:current_user_app].nil? || !params["login"].nil? 
    erb :"protected"
  else
	redirect "http://localhost:4567/appli1/sessions/new?origin=/protected"
  end
end
