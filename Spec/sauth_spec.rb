require_relative 'spec_helper'
require '../sauth'
require 'rack/test'

include Rack::Test::Methods

def app
	Sinatra::Application
end

describe "sauth" do

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

		it "status should return 200 if the user go to get /sauth/app/new" do
			get '/sauth/app/new'
			last_response.status.should == 200
		end

	end

	describe "The user wants to connect" do
	
		before (:each) do
			user = double(User)
			user.stub(:login).and_return('Patrick')
			user.stub(:password).and_return('9d4e1e23bd5b727046a9e3b4b7db57bd8d6ee684')
			User.stub(:find_by_login).with('Patrick').and_return(user)
			user
		end

		context "when the user is registered (but not connected)" do

			it "should user redirect in user page with good login and password" do
				post '/sauth/sessions/register', params={'login' => "Patrick", 'password' => "pass"}	
				follow_redirect!
				last_request.path.should == '/'
			end

			it "should user stay in login page because login is not valid" do
				post '/sauth/sessions/register', params={'login' => "PatPat", 'password' => "pass"}
				#last_response.body.should match %r{<form action="/sauth/register" method="post".*}
				last_request.path.should == '/sauth/sessions/register'
			end

			it "should user stay in login page because password is not valid" do
				post '/sauth/sessions/register', params={'login' => "Patrick", 'password' => "mdp"}
				last_response.should be_ok
				last_request.path.should == '/sauth/sessions/register'
			end
		end

	end

	describe "The user wants to create a new count" do

		context "when the login is not exist in the database" do

			it "should user redirect in user page beacuse informations are good" do
				post '/sauth/sessions/new', params={'login' => "Patrick", 'password' => "pass", 'password_confirmation' => "pass"}
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
				post '/sauth/sessions/new', params={'login' => "_-", 'password' => "pass", 'password_confirmation' => "pass"}
				last_response.should be_ok
				last_request.path.should == '/sauth/sessions/new'
			end

			it "should user stay in inscription page because password is different of password_confirmation" do
				post '/sauth/sessions/new', params={'login' => "Patrick", 'password' => "pass", 'password_confirmation' => "bad_pass"}
				last_response.should be_ok
				last_request.path.should == '/sauth/sessions/new'
			end
		end

		context "when the login exist in the database" do

			it "should stay in inscription page because login exist" do
				user = double(User)
				user.stub(:login).and_return('TOTO')
				user.stub(:password).and_return('password')
				post '/sauth/sessions/new', params={'login' => "TOTO", 'password' => "mdp", 'password_confirmation' => "mdp"}
				last_request.path.should == '/sauth/sessions/new'
			end
		end
	end

	describe "The user wants to create an application" do

		it "should redirect the user in the profil page because the user is connected and the informations are good" do
			user = double(User)
			user.stub(:login).and_return('Patrick')
			user.stub(:password).and_return('password')
			#post '/sauth/sessions/register', params={'login' => "Patrick", 'password' => "password"}
			post '/sauth/app/new', params={'name' => "Patrick_App", 'url' => "url_app"}
			follow_redirect!
			last_request.path.should == '/'	
		end
	
	end
	
	User.all.each{|user| user.destroy}	
end
