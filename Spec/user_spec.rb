require_relative 'spec_helper'
require 'user'

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

		it "should include the password module" do
   			User.included_modules.should include(Password)
		end

		it "should encrypt the password with sha1" do
    		Digest::SHA1.should_receive(:hexdigest).with("foo").and_return("0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33")
			user = User.new
    		user.password="foo"
  		end

  		it "should store she sha1 digest" do
			user = User.new
    		user.password="foo"
    		user.password.should == "0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33"
  		end

		describe "user authentication"  do 

    		it "should crypt the clear password given" do 
				user = User.new
      			Digest::SHA1.should_receive(:hexdigest).with("foo").and_return("0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33")
      			user.authenticate("foo")
  			end
		end

		describe "authentication with password challenge" do
	
			it "should return valid authentication" do
				user = User.new
				user.login = "Patrick"
				user.password = "foo"
				user.authenticate("foo").should be_true
			end

			it "should return invalid authentication" do
				user = User.new
				user.login = "Patrick"
				user.password = "foo"
          		user.authenticate("bad pass").should be_false
			end
		end
	end
end
