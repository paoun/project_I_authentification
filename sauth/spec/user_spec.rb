require_relative 'spec_helper'
require 'user'
require 'digest/sha1'

describe User do

	describe "Missing informations" do

		before (:each) do
			@user = User.new
		end

		after(:each) do
			@user.destroy
		end

		it "should not be valid without login" do
			@user.password = "pass"
			@user.valid?.should be_false
		end

		it "should not be valid without password" do
			@user.login = "Patrick"
			@user.valid?.should be_false
		end

		it "should not be valid without login and password" do
			@user.valid?.should be_false
		end

	end

	describe "Information not unique" do

		before (:each) do
			@user = User.new
			@user.login = "Patrick"
			@user.password = "pass1"
			@user.save
		end

		after(:each) do
			@user.destroy
		end

 		it "should not be valid with two identical logins" do
			user1 = User.new
			user1.login = "Patrick"
			user1.password = "pass2"
			user1.valid?.should be_false
		end

	end

	describe "Check password" do

		before (:each) do
			@user = User.new
			@user.login = "Patrick"
			@user.save
		end

		after(:each) do
			@user.destroy
		end

		it "should encrypt the password with sha1" do
			Digest::SHA1.should_receive(:hexdigest).with("pass").and_return("9d4e1e23bd5b727046a9e3b4b7db57bd8d6ee684")
			@user.password = "pass"
			@user.password.should == '9d4e1e23bd5b727046a9e3b4b7db57bd8d6ee684'
  		end

  		it "should store she sha1 digest" do
    		@user.password="pass"
    		@user.password.should == Digest::SHA1.hexdigest("pass").inspect[1..40]
  		end

		describe "authentication with password" do

			before (:each) do
				@user = User.new
				@user.stub(:login).and_return("Patrick")
				@user.stub(:password).and_return("9d4e1e23bd5b727046a9e3b4b7db57bd8d6ee684")
			end

			after(:each) do
				@user.destroy
			end
	
			it "should return valid authentication" do
				User.should_receive(:find_by_login).with("Patrick").and_return(@user)
				User.authenticate("Patrick", "pass").should be_true
			end

			it "should return invalid authentication" do
				User.should_receive(:find_by_login).with("Patrick").and_return(@user)
				User.authenticate('Patrick', 'bad_pass').should be_false
			end
		end
	end

	describe "Check login" do
	
		before(:each) do
			@user = User.new
			@user.stub(:login).and_return('Patrick')
			@user.stub(:password).and_return('9d4e1e23bd5b727046a9e3b4b7db57bd8d6ee684')
		end

		it "should return true because the login format is good" do
			User.should_receive(:find_by_login).with('Patrick').and_return(@user)
			User.authenticate('Patrick', 'pass').should be_true
		end

		it "should return false because login is short" do
			@user.stub(:login).and_return("Bad")
			@user.valid?.should be_false
		end

		it "should return false because login have special caracter" do
			@user.stub(:login).and_return("Bad_-_-_-")
			@user.valid?.should be_false
		end		
	end

	describe "Delete an user" do

		before(:each) do
			@user = User.new
			@user.login = 'Patrick'
			@user.password = "pass"
			@user.id = 10
			@user.save
		end

		after(:each) do
			@user.destroy
		end
		
		it "should delete the user with success" do
			User.find_by_id(10).should_not be_nil
			User.delete_users(10)
			User.find_by_id(10).should be_nil
		end

	end
end
