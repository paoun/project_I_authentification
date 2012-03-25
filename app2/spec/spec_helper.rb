require 'rack/test'

require '../appli2'

include Rack::Test::Methods

def app
  Sinatra::Application
end
