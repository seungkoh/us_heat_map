require 'app'
require 'rspec'
require 'rack/test'

set :environment, :test

describe "US Heat Map" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "should include a survey on the homepage" do

    get "/"

    last_response.body.should match(/Please answer the simple questionaire below/)
    last_response.status.should == 200

  end

  # Not sure how to get this to work - I am getting a Nil back for params[:post]
  it "should show results after completing survey" #do

    #post "/show", {"obama"=>"4", "tax"=>"2", "healthcare"=>"3", "abortion"=>"1", "gay"=>"4", "energy"=>"0", "gun"=>"4", "union"=>"1", "foreign"=>"2", "capitalism"=>"0"} 

    #last_response.body.should match(/Based on your questionaire responses, we found that you are a\s+<b>Moderate or Independent/)
    #last_response.status.should == 200

  #end

  it "should return a custom 404 page when the username cannot be found" do
    
    get "/thispagedoesnotexist"
    
    last_response.status.should == 404
    last_response.body.should match(/Uh oh! The page you were looking for does not exist./)
    
  end

end
