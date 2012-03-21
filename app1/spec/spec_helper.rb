require 'rack/test'

require '../appli1'

include Rack::Test::Methods

def app
  Sinatra::Application
end
