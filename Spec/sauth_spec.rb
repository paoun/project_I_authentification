require_relative 'spec_helper'
require '../sauth'
require 'rack/test'

include Rack::Test::Methods

def app
	Sinatra::Application
end

describe "the authentication" do

	describe "The user wants to acces at register page" do

		it "status should return 200 if the user go to /sauth/register" do
			get '/sauth/appli_cliente_1/register'
			last_response.status.should == 200
		end

	end

	describe "The user wants to connect" do

		context "when the user is registered" do

			it "should redirect user with login not valid" do
				user = User.new
				user.login = "Pat"
				user.password = "pass"
				user.save
				post '/sauth/sessions', params={'login' => "PatPat", 'password' => "pass"}
				last_response.status.should == 302
				last_response.headers["Location"].should == 'http://example.org/sauth/appli_cliente_1/new?info=Login_Not_Exist'
			end

			it "should redirect user with password not valid" do
				user = User.new
				user.login = "Pat"
				user.password = "pass"
				user.save
				post '/sauth/sessions', params={'login' => "Pat", 'password' => "mdp"}
				last_response.status.should == 302
				last_response.headers["Location"].should == 'http://example.org/sauth/appli_cliente_1/new?info=Pass_Not_Valid'
			end
		end

		context "when the user is not registered" do
		
			it "should redirect user at /sauth/appli_cliente_1/new?info=login_not_exist" do
				post '/sauth/sessions', params={'login' => "Patrick", 'password' => "pass"}
				last_response.status.should == 302
				last_response.headers["Location"].should == 'http://example.org/sauth/appli_cliente_1/new?info=Login_Not_Exist'
			end
		end
	end

	describe "The user wants to registered" do

		context "when the login is not exist" do

			it "should redirect user at /sauth/appli_cliente_1/register?info=Missing_Login_Or_Password because missing login or password" do
				post '/sauth/register', params={'password' => "pass"}
				last_response.status.should == 302
				last_response.headers["Location"].should == 'http://example.org/sauth/appli_cliente_1/register?info=Missing_Login_Or_Password'			
			end

			it "should redirect user at /sauth/appli_cliente_1/new?info=Welcome_Now_You_Can_Connect" do
				post '/sauth/register', params={'login' => "Patrick", 'password' => "pass"}
				last_response.status.should == 302
				last_response.headers["Location"].should == 'http://example.org/sauth/appli_cliente_1/new?info=Welcome_Now_You_Can_Connect'
			end
		end

		context "when the login exist" do

			it "should redirect user at /sauth/appli_cliente_1/register?info=Login_Used because login exist" do
				user = User.new
				user.login = "TOTO"
				user.password = "pass"
				user.save
				post '/sauth/register', params={'login' => "TOTO", 'password' => "mdp"}
				last_response.status.should == 302
				last_response.headers["Location"].should == 'http://example.org/sauth/appli_cliente_1/register?info=Login_Used'
			end
		end
	User.all.each{|user| user.destroy}
	end
end
