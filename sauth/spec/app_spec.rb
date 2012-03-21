require_relative 'spec_helper'
require 'app'

describe App do

	describe "Missing informations" do

		before(:each) do
			@app = App.new
		end

		after(:each) do
			@app.destroy
		end

		it "should not be valid without name" do
			@app.url = "http://url.aoun"
			@app.valid?.should be_false
		end

		it "should not be valid without url" do
			@app.name = "AppAoun"
			@app.valid?.should be_false
		end

		it "should not be valid without url and without name" do
			@app.valid?.should be_false
		end

		it "should not be valid because url is not valid" do
			@app.name = "AppAoun"
			@app.url = "url"
		end
	end

	describe "Information not unique" do
		
		before(:each) do
			@app = App.new
			@app.name = "AppAoun"
			@app.url = "http://url.aoun"
			@app.admin = "Patrick"
			@app.save
		end

		after(:each) do
			@app.destroy
		end

		it "should not be valid with two identical name" do
			app1 = App.new
			app1.name = "AppAoun"
			app1.url = "http://youpii"
			app1.admin = "Admin"

			app1.valid?.should be_false
		end

		it "should not be valid with two identical url" do
			app1 = App.new
			app1.name = "NameApp"
			app1.url = "http://url.aoun"
			app1.admin = "Admin"

			app1.valid?.should be_false
		end
	end

	describe "Methods" do

		before(:each) do
			@app = App.new
			@app.name = "AppAoun"
			@app.url = "http://url.aoun"
			@app.admin = "Patrick"
			@app.save
		end

		after(:each) do
			@app.destroy
		end

		it "exist? method" do
			App.exist?("AppAoun").should == true
		end

		it "get_apps method" do
			@app2 = App.new
			@app2.name = "AppAoun2"
			@app2.url = "http://url.aoun2"
			@app2.admin = "Patrick"
			@app2.save

			App.get_apps("Patrick").length.should == 2
		end

		it "delete_apps method" do

			@user = User.new
			@user.login = "Patrick"
			@user.password = "pass"
			@user.save

			App.find_by_name('AppAoun').should_not be_nil
			App.delete_apps(@app.id, @user.login)
			App.find_by_name('AppAoun').should be_nil
		end

		it "redirect methode" do
			@user = User.new
			@user.login = "Patrick"
			@user.password = "pass"
			@user.save

			App.redirect(@app, '/protected', @user).should == 'http://url.aoun/protected?login=Patrick&secret=secret'
		end
	end
end
