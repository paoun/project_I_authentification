require 'spec_helper'
require 'uri'

describe 'appli1' do

	describe " get /" do

		it "should ok" do
			get '/'
			last_response.should be_ok
		  	last_request.path.should == '/'
		end
	end

  describe "get /protected" do

    before do
              @params = { 'secret' => "secret", "login" => "paoun"}
    end

	it "should redirect the user because he is not connected" do
		get '/protected'
    	last_response.should be_redirect
        follow_redirect!
        last_request.url.should == 'http://localhost:4567/appli1/sessions/new?origin=%2Fprotected'
	end

	it "should redirect to protected" do      
        get '/protected', @params
		last_response.should be_ok
        last_request.path.should == '/protected'
    end
  end
end
