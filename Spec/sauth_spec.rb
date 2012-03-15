require_relative 'spec_helper'
require '../sauth'
require 'rack/test'

include Rack::Test::Methods

def app
	Sinatra::Application
end

describe "sauth" do

	before (:each) do
		User.all.each{|user| user.destroy}
		App.all.each{|app| app.destroy}
	end

	describe "The user wants to acces at differents pages" do

		it "status should return 200 if the user go to /" do
			get '/'
			last_response.status.should == 200
		end

		it "status should return 200 if the user go to /:current_user" do
			get '/:current_user'
			last_response.status.should == 200
		end

		it "status should return 200 if the user go to /sauth/sessions/new" do
			get '/sauth/sessions/new'
			last_response.body.should match %r{<form action="/sauth/sessions/new" method="post".*}
			last_response.status.should == 200
		end

		it "satus should return 200 if the user go to /sauth/sessions/register" do
			get '/sauth/sessions/register'
			last_response.body.should match %r{<form action="/sauth/sessions/register" method="post".*}
			last_response.status.should == 200
		end

		it "status should return 200 if the user go to /sauth/app/new" do
			get '/app/new'
			last_response.status.should == 200
		end

	end

	describe "post /sauth/sessions/register" do
	
		before (:each) do
			@params_user={'login' => "Patrick", 'password' => "pass"}
			@user = double(User)
			@user.stub(:login).and_return('Patrick')
			@user.stub(:password).and_return('9d4e1e23bd5b727046a9e3b4b7db57bd8d6ee684')
			@user.stub(:save)
		end

		it "should authenticate with success" do
			User.should_receive(:find_by_login).at_least(1).with('Patrick').and_return(@user)
			post '/sauth/sessions/register', @params_user	
			follow_redirect!
			last_request.path.should == '/'
			last_request.env['rack.session']['current_user'].should == 'Patrick'
		end

		it "should not authenticate with success" do
			post '/sauth/sessions/register', @params_user
			last_response.should be_ok
			last_request.path.should == '/sauth/sessions/register'
		end

		it "should not authenticate because password is not valid" do
			User.should_receive(:find_by_login).at_least(1).with('Patrick').and_return(@user)
			post '/sauth/sessions/register', params={'login' => "Patrick", 'password' => "mdp"}
			last_response.should be_ok
			last_request.path.should == '/sauth/sessions/register'
		end

		it "should not authenticate because login is not exist" do
			post '/sauth/sessions/register', @params_user
			last_response.should be_ok
			last_request.path.should == '/sauth/sessions/register'
		end	
	end

	describe "post /sauth/sessions/new" do

		before (:each) do
			@params_user={'login' => "Patrick", 'password' => "pass", 'password_confirmation' => "pass"}
		end	

		it "should create with success" do
				post '/sauth/sessions/new', @params_user
				last_request.env['rack.session']['current_user'].should == 'Patrick'
				last_response.status.should == 302
				last_response.should be_redirect
				follow_redirect!
				last_request.path.should == '/'
		end

		it "should user stay in inscription page because login is not present" do
			post '/sauth/sessions/new', params={'password' => "pass", 'password_confirmation' => "pass"}
			last_response.should be_ok
			last_request.path.should == '/sauth/sessions/new'
		end

		it "should user stay in inscription page because login is not good" do
			@params_user['login'] = "_-Pat-_"
			post '/sauth/sessions/new', @params_user
			last_response.should be_ok
			last_request.path.should == '/sauth/sessions/new'
		end

		it "should user stay in inscription page because password is different of password_confirmation" do
			@params_user['password_confirmation'] = "bad_pass"
			post '/sauth/sessions/new', @params_user
			last_response.should be_ok
			last_request.path.should == '/sauth/sessions/new'
		end

		it "should stay in inscription page because login exist" do
			post '/sauth/sessions/new', @params_user
			get '/sauth/sessions/disconnect'
			post '/sauth/sessions/new', params={'login' => "Patrick", 'password' => "mdp", 'password_confirmation' => "mdp"}
			last_response.should be_ok
			last_request.path.should == '/sauth/sessions/new'
		end
	end

	describe "post /app/new" do

		before (:each) do
			@params_app={'name' => "App", 'url' => "http://App"}
			@params_user={'login' => "Patrick", 'password' => "pass", 'password_confirmation' => "pass"}
			@user = double(User)
			@user.stub(:login).and_return('Patrick')
			@user.stub(:password).and_return('9d4e1e23bd5b727046a9e3b4b7db57bd8d6ee684')
			@user.stub(:save)
		end

		it "should create with success" do
			User.should_receive(:find_by_login).at_least(1).with('Patrick').and_return(@user)
			post '/sauth/sessions/register', @params_user
			post '/app/new', @params_app
			follow_redirect!
			last_request.path.should == '/'	
		end

		it "should not create with success (bad url)" do
			User.should_receive(:find_by_login).at_least(1).with('Patrick').and_return(@user)
			post '/sauth/sessions/register', @params_user
			@params_app['url'] = "bad_url"
			post '/app/new', @params_app
			last_response.status.should == 200
			last_request.path.should == '/app/new'
		end

		it "should not create with success (user is not connected)" do
			get '/sauth/sessions/disconnect'
			post '/app/new', @params_app
			follow_redirect!
			last_request.path.should == '/'
		end
	
	end

	describe "get /app/delete" do

		before (:each) do
			post '/sauth/sessions/new', params={'login' => "Patrick", 'password' => "password", 'password_confirmation' => "password"}
			post '/app/new', params={'name' => "Patrick_App", 'url' => "http://app"}
			app = App.find_by_name("Patrick_App")
			@app_id = app.id
		end

		it "should delete the application with success" do
			app = App.find_by_name("Patrick_App")
			app.nil?.should == false
			get "/app/delete?app=#{app.id}"
			follow_redirect!
			last_request.path.should == '/'
			app = App.find_by_id(@app_id)
			app.nil?.should == true
		end

		it "should not delete with success (not connected)" do	
			get '/sauth/sessions/disconnect'
			app = App.find_by_name("Patrick_App")
			app.nil?.should == false
			get "/app/delete?app=#{app.id}"
			follow_redirect!
			last_request.path.should == '/'
			app = App.find_by_id(@app_id)
			app.nil?.should == false
		end

		it "should not delete with success (application not exist)" do
			get "/app/delete?app=9999999"
			follow_redirect!
			last_request.path.should == '/'
		end	

		it "should not delete with success (not admin)" do
			get '/sauth/sessions/disconnect'
			post '/sauth/sessions/new', params={'login' => "NewLogin", 'password' => "password", 'password_confirmation' => "password"}
			app = App.find_by_name("Patrick_App")
			app.nil?.should == false
			get "/app/delete?app=#{app.id}"
			follow_redirect!
			last_request.path.should == '/'
			app = App.find_by_id(@app_id)
			app.nil?.should == false
			
		end	
	end

	describe "get /sauth/admin" do

		before (:each) do
			@params_admin = {'login' => "admin", 'password' => "password", 'password_confirmation' => "password"}
			post '/sauth/sessions/new', @params_admin
		end

		it "should redirect in admin page with success (login = admin)" do
			post '/sauth/sessions/new', @params_admin
			last_request.env['rack.session']['current_user'].should == 'admin'
			get '/sauth/admin'
			last_request.path.should == '/sauth/admin'
		end

		it "should redirect in the profil page (not admin page, login /= admin)" do
			get '/sauth/sessions/disconnect'
			@params_admin['login'] = "Patrick"
			post '/sauth/sessions/new', @params_admin
			last_request.env['rack.session']['current_user'].should == 'Patrick'
			get '/sauth/admin'
			follow_redirect!
			last_request.path.should == '/'
		end

		it "should redirect in the main (not connected)" do
			get '/sauth/sessions/disconnect'
			get '/sauth/admin'
			follow_redirect!
			last_request.path.should == '/'
		end
	end

	describe "get /sauth/users/delete" do

		before (:each) do
			@params_admin = {'login' => "admin", 'password' => "password", 'password_confirmation' => "password"}
			@params_user = {'login' => "login", 'password' => "password", 'password_confirmation' => "password"}
			post '/sauth/sessions/new', @params_user
			get '/sauth/sessions/disconnect'
			post '/sauth/sessions/new', @params_admin
			@user = User.find_by_login("login")
			@user_id = @user.id
		end
		
		it "should delete the user with success" do
			@user.nil?.should == false
			get "/sauth/users/delete?user=#{@user_id}"
			follow_redirect!
			last_request.path.should == '/sauth/admin'
			user = User.find_by_id(@user_id)
			user.nil?.should == true
		end

		it "should not delete the user with success (not admin)" do
			get '/sauth/sessions/disconnect'
			post '/sauth/sessions/new', {'login' => "Patrick", 'password' => "password", 'password_confirmation' => "password"}
			@user.nil?.should == false
			get "/sauth/users/delete?user=#{@user_id}"
			follow_redirect!
			last_request.path.should == '/'
			user = User.find_by_id(@user_id)
			user.nil?.should == false
		end

		it "should not delete the user with success (user not exist)" do
			get "/sauth/users/delete?user=999999999"
			follow_redirect!
			last_request.path.should == '/sauth/admin'
		end
	end
end
