require_relative 'spec_helper'
require '../sauth'
require 'rack/test'

include Rack::Test::Methods

def app
	Sinatra::Application
end

describe "sauth" do

	before (:each) do
		App.destroy_all
		User.destroy_all
		Use.destroy_all
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
			get '/sessions/new'
			last_response.status.should == 200
		end

		it "satus should return 200 if the user go to /sauth/sessions/register" do
			get '/users/new'
			last_response.status.should == 200
		end

		it "status should return 200 if the user go to /app/new" do
			get '/app/new'
			last_response.status.should == 200
		end

	end

	describe "post /users" do

		context "there is not an origin" do

			before (:each) do
				@params_user={'login' => "Patrick", 'password' => "pass", 'password_confirmation' => "pass"}
			end	

			it "should create with success" do
				post '/users', @params_user
				last_request.env['rack.session']['current_user'].should == 'Patrick'
				last_response.status.should == 302
				last_response.should be_redirect
				follow_redirect!
				last_request.path.should == '/'
			end

			it "should user stay in inscription page because login is not present" do
				@params_user[:login]=""
				post '/users', @params_user 
				last_response.should be_ok
				last_request.path.should == '/users'
			end

			it "should user stay in inscription page because login is not good" do
				@params_user['login'] = "_-Pat-_"
				post '/users', @params_user
				last_response.should be_ok
				last_request.path.should == '/users'
			end

			it "should user stay in inscription page because password is different of password_confirmation" do
				@params_user['password_confirmation'] = "bad_pass"
				post '/users', @params_user
				last_response.should be_ok
				last_request.path.should == '/users'
			end

			it "should stay in inscription page because login exist" do
				post '/users', @params_user
				get '/sessions/disconnect'
				post '/users', params={'login' => "Patrick", 'password' => "mdp", 'password_confirmation' => "mdp"}
				last_response.should be_ok
				last_request.path.should == '/users'
			end
		end

		context "With an origin" do

			before (:each) do
				@params_user={'login' => "Patrick", 'password' => "pass", 'password_confirmation' => "pass"}
				@app = App.new
				@app.stub(:url).and_return('http://app.fr')
				@app.stub(:name).and_return('app')
				@app.stub(:admin).and_return('Login')
			end	

			it "should create with success and redirect the user at the app page" do
				App.should_receive(:find_by_name).with('app').and_return(@app)
				post '/users?origin=/protected&nameapp=app', @params_user
				last_request.env['rack.session']['current_user'].should == 'Patrick'
				last_response.should be_redirect
				follow_redirect!
				last_request.url.should == 'http://app.fr/protected?login=Patrick&secret=secret'
			end

			it "should user stay in inscription page because login is not present" do
				@params_user[:login]=""
				post '/users?origin=/protected&nameapp=app', @params_user 
				last_response.should be_ok
				last_request.path.should == '/users'
			end

			it "should user stay in inscription page because login is not good" do
				@params_user['login'] = "_-Pat-_"
				post '/users?origin=/protected&nameapp=app', @params_user
				last_response.should be_ok
				last_request.path.should == '/users'
			end

			it "should user stay in inscription page because password is different of password_confirmation" do
				@params_user['password_confirmation'] = "bad_pass"
				post '/users?origin=/protected&nameapp=app', @params_user
				last_response.should be_ok
				last_request.path.should == '/users'
			end

			it "should stay in inscription page because login exist" do
				post '/users', @params_user
				get '/sessions/disconnect'
				post '/users?origin=/protected&nameapp=app', params={'login' => "Patrick", 'password' => "mdp", 'password_confirmation' => "mdp"}
				last_response.should be_ok
				last_request.path.should == '/users'
			end
		end
	end
	
	describe "post /sessions" do

		before (:each) do
				@params_user={'login' => "Patrick", 'password' => "pass"}
				@user=User.new
				@user.stub(:login).and_return('Patrick')
				@user.stub(:password).and_return('pass')
		end

		context "good authentication" do

			before do
				User.should_receive(:authenticate).with('Patrick', 'pass').and_return(@user)
				User.should_receive(:find_by_login).with('Patrick').and_return(@user)
			end
			

			it "should authenticate with success" do
				post '/sessions', @params_user
				last_response.should be_redirect
				follow_redirect!
				last_request.path.should == '/'
				last_response.headers["Set-Cookie"].should be_true
			end

		end	

		context "Bad authentication" do	

			before do
				User.should_receive(:authenticate).with('Patrick', 'pass').and_return(nil)
			end

			it "should not authenticate with success" do
				post '/sessions', @params_user
				last_response.should be_ok
				last_request.path.should == '/sessions'
			end

			it "should not authenticate because password is not valid" do
				User.should_receive(:find_by_login).with('Patrick').and_return(@user)
				post '/sessions', @params_user
				last_response.should be_ok
				last_request.path.should == '/sessions'
			end

			it "should not authenticate because login is not exist" do
				User.should_receive(:find_by_login).with('Patrick').and_return(nil)
				post '/sessions', params={'login' => "Patrick", 'password' => "pass"}
				last_response.should be_ok
				last_request.path.should == '/sessions'
			end	

		end

	end

	describe "get /:app_name/sessions/new" do
		
		before(:each) do
			@app = App.new
			@app.stub(:url).and_return('http://app.fr')
			@app.stub(:name).and_return('app')
			@app.stub(:admin).and_return('Patrick')
			@user=User.new
			@user.stub(:login).and_return('Patrick')
			@user.stub(:password).and_return('pass')
		end


		describe "The user is connected" do

			before(:each) do
				User.should_receive(:authenticate).with('Patrick', 'pass').and_return(@user)
				User.should_receive(:find_by_login).with('Patrick').and_return(@user)
				App.should_receive(:find_by_name).with('app').and_return(@app)
				post '/sessions', params={'login' => 'Patrick', 'password' => 'pass'}
			end

			after(:each) do
				post '/disconnect'
			end

			it "should redirect the user to the origin page of the application" do
				User.should_receive(:find_by_login).with('Patrick').and_return(@user)
				get '/app/sessions/new?origin=/protected'
				last_response.should be_redirect
				follow_redirect!
				last_request.url.should == 'http://app.fr/protected?login=Patrick&secret=secret'
			end
		end


		describe "The user is not connected" do

			it "should render the form which allows the user to authenticate on the authentication service " do
				get '/app/sessions/new?origin=/protected'
				last_response.should be_ok
				last_request.path.should == '/app/sessions/new'
			end
		end
	end

	describe "post /:app_name/sessions" do

		before(:each) do
			@app = App.new
			@app.stub(:url).and_return('http://app.fr')
			@app.stub(:name).and_return('app')
			@app.stub(:admin).and_return('Patrick')
			@user=User.new
			@user.stub(:login).and_return('Patrick')
			@user.stub(:password).and_return('pass')
		end

		describe "The user is connected" do

			before(:each) do
				User.should_receive(:authenticate).with('Patrick', 'pass').and_return(@user)
				User.should_receive(:find_by_login).with('Patrick').and_return(@user)
				App.should_receive(:find_by_name).with('app').and_return(@app)
				post '/sessions', params={'login' => 'Patrick', 'password' => 'pass'}
			end

			after(:each) do
				post '/disconnect'
			end

			it "should redirect the user to the origin page of the application" do
				User.should_receive(:find_by_login).with('Patrick').and_return(@user)
				post '/app/sessions?origin=/protected'
				last_response.should be_redirect
				follow_redirect!
				last_request.url.should == 'http://app.fr/protected?login=Patrick&secret=secret'
			end
		end


		describe "The user is not connected" do

			it "should render the form which allows the user to authenticate on the authentication service " do
				post '/app/sessions?origin=/protected'
				last_response.should be_ok
				last_request.path.should == '/app/sessions'
			end
		end
	
	end

	
	context "creation and delete of applications" do

		before (:each) do
			@user=User.new
			@user.stub(:login).and_return('Patrick')
			@user.stub(:password).and_return('pass')
			User.should_receive(:authenticate).with('Patrick', 'pass').and_return(@user)
			User.should_receive(:find_by_login).with('Patrick').and_return(@user)
			post '/sessions', params={'login' => "Patrick", 'password' => "pass"}
		end

		describe "post /app" do

			before (:each) do
				@params_app={'name' => "Patrick_App", 'url' => "http://App"}
			end

			it "should create with success" do
				post '/app', @params_app
				app = App.find_by_name("Patrick_App")
				app.nil?.should == false
				follow_redirect!
				last_request.path.should == '/'	
			end

			it "should not create with success (bad url)" do
				@params_app['url'] = "bad_url"
				post '/app', @params_app
				last_request.path.should == '/app'
			end

			it "should not create with success (user is not connected)" do
				post '/disconnect'
				post '/app', @params_app
				follow_redirect!
				last_request.path.should == '/'
			end
	
		end

		describe "get /app/delete" do

			before(:each) do
				@app = App.new
				@app.name = "Patrick_App"
				@app.url = "http://app.fr"
				@app.admin = "Patrick"
				@app.id = 10
				@app.save
			end
	
			after(:each) do
				@app.destroy
			end

			it "should delete the application with success" do
				app = App.find_by_name("Patrick_App")
				app.nil?.should == false
				app.name.should == "Patrick_App"
				get "/app/delete?app=10"
				app = App.find_by_id(10)
				app.nil?.should == true
				follow_redirect!
				last_request.path.should == '/'
			end

			it "should not delete with success (not connected)" do	
				get '/sessions/disconnect'
				app = App.find_by_name("Patrick_App")
				app.nil?.should == false
				get "/app/delete?app=10"
				app = App.find_by_id(10)
				app.nil?.should == false
				follow_redirect!
				last_request.path.should == '/'

			end

			it "should not delete with success (application not exist)" do
				get "/app/delete?app=9999999"
				app = App.find_by_id(9999999)
				app.nil?.should == true
				follow_redirect!
				last_request.path.should == '/'
			end	

			it "should not delete with success (not admin)" do
				get '/sessions/disconnect'
				post '/users', params={'login' => "NewLogin", 'password' => "password", 'password_confirmation' => "password"}
				app = App.find_by_name("Patrick_App")
				app.nil?.should == false
				get "/app/delete?app=10"
				app = App.find_by_id(10)
				app.nil?.should == false
				follow_redirect!
				last_request.path.should == '/'
			end	
		end
	end

	describe "get /sauth/admin" do

		before (:each) do
			@user=User.new
			@user.stub(:login).and_return('admin')
			@user.stub(:password).and_return('pass')
			User.should_receive(:authenticate).with('admin', 'pass').and_return(@user)
			User.should_receive(:find_by_login).with('admin').and_return(@user)
			post '/sessions', params={'login' => "admin", 'password' => "pass"}
		end

		it "should redirect in admin page with success (login = admin)" do
			last_request.env['rack.session']['current_user'].should == 'admin'
			get '/sauth/admin'
			last_request.path.should == '/sauth/admin'
		end

		it "should redirect in the profil page (not admin page, login /= admin)" do
			get '/sessions/disconnect'
			@userNotAdmin=User.new
			@userNotAdmin.stub(:login).and_return('Patrick')
			@userNotAdmin.stub(:password).and_return('pass')
			User.should_receive(:authenticate).with('Patrick', 'pass').and_return(@userNotAdmin)
			User.should_receive(:find_by_login).with('Patrick').and_return(@userNotAdmin)
			post '/sessions', params={'login' => "Patrick", 'password' => "pass"}
			last_request.env['rack.session']['current_user'].should == 'Patrick'
			get '/sauth/admin'
			follow_redirect!
			last_request.path.should == '/'
			follow_redirect!
			last_request.path.should == '/Patrick'
		end

		it "should redirect in the main page (not connected)" do
			get '/sessions/disconnect'
			get '/sauth/admin'
			follow_redirect!
			last_request.path.should == '/'
		end
	end

	describe "get /sauth/users/delete" do

		before (:each) do
			@admin = User.new
			@admin.login = "admin"
			@admin.password = "pass"
			@admin.id = 1
			@admin.save
			
			@user = User.new
			@user.login = "Patrick"
			@user.password = "pass"
			@user.id = 10
			@user.save

			@params_admin = {'login' => "admin", 'password' => "pass"}
			@params_user = {'login' => "Patrick", 'password' => "pass"}


		end
		
		it "should delete the user with success (the user is the admin)" do
			post '/sessions', @params_admin
			user = User.find_by_id(10)
			user.nil?.should == false
			get "/sauth/users/delete?user=10"
			user = User.find_by_id(10)
			user.nil?.should == true
			follow_redirect!
			last_request.path.should == '/sauth/admin'
		end

		it "should not delete the user with success (not admin)" do
			get '/sessions/disconnect'
			post '/sessions', @params_user 
			user = User.find_by_id(10)
			user.nil?.should == false
			get "/sauth/users/delete?user=10"
			user = User.find_by_id(10)
			user.nil?.should == false
			follow_redirect!
			last_request.path.should == '/'
			follow_redirect!
			last_request.path.should == '/Patrick'
		end

		it "should not delete the user with success (user not exist)" do
			get '/sessions/disconnect'
			post '/sessions', @params_admin
			get "/sauth/users/delete?user=999999999"
			follow_redirect!
			last_request.path.should == '/sauth/admin'
		end
	end
end
