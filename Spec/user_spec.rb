require_relative 'spec_helper'
require 'user'
require 'digest/sha1'

describe User do

	describe "Missing informations" do

		it "should not be valid without login" do
			user = User.new
			user.password = "pass"
			user.valid?.should be_false
		end

		it "should not be valid without password" do
			user = User.new
			user.login = "Patrick"
			user.valid?.should be_false
		end

		it "should not be valid without login and password" do
			user = User.new
			user.valid?.should be_false
		end

	end

	describe "Information not unique" do

 		it "should not be valid with two identical logins" do
			user = User.new
			user.login = "Patrick"
			user.password = "pass1"
			user.save

			user1 = User.new
			user1.login = "Patrick"
			user1.password = "pass2"

			user1.valid?.should be_false
		end

	end

	describe "Check password" do

		it "should encrypt the password with sha1" do
			user = User.new
			user.login = "Patrick"
			Digest::SHA1.should_receive(:hexdigest).with("pass").and_return("9d4e1e23bd5b727046a9e3b4b7db57bd8d6ee684")
			user.password = "pass"
			user.password.should == '9d4e1e23bd5b727046a9e3b4b7db57bd8d6ee684'

  		end

  		it "should store she sha1 digest" do
			user = User.new
    		user.password="pass"
    		user.password.should == Digest::SHA1.hexdigest("pass").inspect[1..40]
  		end

		describe "authentication with password challenge" do
	
			it "should return valid authentication" do
				user = double(User)
				user.stub(:login).and_return('Patrick')
				user.stub(:password).and_return('9d4e1e23bd5b727046a9e3b4b7db57bd8d6ee684')
				User.stub(:find_by_login).with('Patrick').and_return(user)
				User.authenticate('Patrick', 'pass').should be_true
			end

			it "should return invalid authentication" do
				user = double(User)
				user.stub(:login).and_return('Patrick')
				user.stub(:password).and_return('9d4e1e23bd5b727046a9e3b4b7db57bd8d6ee684')
				User.stub(:find_by_login).with('Patrick').and_return(user)
				User.authenticate('Patrick', 'bad pass').should be_false
			end
		end
	end

	describe "Check login" do
	
		it "should return true because the login format is good" do
			user = double(User)
			user.stub(:login).and_return('GoodLogin')
			user.stub(:password).and_return('9d4e1e23bd5b727046a9e3b4b7db57bd8d6ee684')
			User.stub(:find_by_login).with('Patrick').and_return(user)
			User.authenticate('Patrick', 'pass').should be_true
		end

		it "should return false because login is short" do
			user = User.new
			user.login = "Bad"
			user.password = "pass"
			user.valid?.should be_false
		end

		it "should return false because login have special caracter" do
			user = User.new
			user.login = "Bad_-_-_-"
			user.password = "pass"
			user.valid?.should be_false
		end		
	end
end
