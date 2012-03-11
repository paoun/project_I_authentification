require_relative 'spec_helper'
require 'app'

describe App do

	describe "Missing informations" do

		it "should not be valid without name" do
			app = App.new
			app.url = "http://url.aoun"
			app.valid?.should be_false
		end

		it "should not be valid without url" do
			app = App.new
			app.name = "AppAoun"
			app.valid?.should be_false
		end

		it "should not be valid without url and without name" do
			app = App.new
			app.valid?.should be_false
		end

		it "should not be valid because url is not valid" do
			app = App.new
			app.name = "AppAoun"
			app.url = "url"
		end
	end

	describe "Information not unique" do
		
		it "should not be valid with two identical name" do
			app = App.new
			app.name = "AppAoun"
			app.url = "http://url.aoun"
			app.save

			app1 = App.new
			app1.name = "AppAoun"
			app1.url = "http://youpii"
			
			app1.valid?.should be_false
		end

		it "should not be valid with two identical url" do
			app = App.new
			app.name = "AppAoun"
			app.url = "http://url.aoun"
			app.save

			app1 = App.new
			app1.name = "NameApp"
			app1.url = "http://url.aoun"

			app1.valid?.should be_false
		end
	end
end
