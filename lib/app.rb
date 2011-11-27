require 'sinatra'
require 'haml'
require 'data_mapper'
require 'dm-aggregates'
require 'geocoder'

# Connect to Heroku database if online; otherwise, use local development database
# Use default adapter for sqlite3
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class PollTaker
  include DataMapper::Resource 
  
  property  :id,            Serial
  property  :ip_address,    String
  property  :city,          String
  property  :state_short,   String
  property  :state,         String
  property  :score,         Integer
  property  :party,         String
end

# Apply changes to DB schema every time model is loaded in development environment
configure :development do  
  DataMapper.auto_upgrade!  
end  

set :views, settings.root + '/../views'
set :public_folder, settings.root + '/../public'

TITLE = "Find Your Political Affiliation"

set :haml, :format => :html5

get '/' do
  @title = TITLE + " - Take the Survey"
  #record = PollTaker.first(:ip_address => request.ip)
  #@ip_exists = record.nil? ? false : true
  haml :index
end

post '/show' do
  @title =  TITLE + " - Survey Results"

  # Pick out radio button selections from params hash to compute score
  score_array = params[:post].flatten.select { |item| item.match(/[0-4]/) }.map { |item| item.to_i * 2.5 }
  max_score = Float(score_array.size * 10)
  submitted_score = score_array.inject{ |sum,x| sum + x }
  
  case submitted_score
    when 0..15
      @party_affiliation = "Strong Republican"
      @party_description = "Your favorite television station is probably Fox News, and you think Bill O'Reilly is a genius. " +
                           "Most likely, you go to church every Sunday, you're into Nascar, and you own a gun."
    when 16..40
      @party_affiliation = "Republican"
      @party_description = "You're not very well read, but you know in your heart that capitalism works and global warming is a myth."
    when 41..59
      @party_affiliation = "Moderate or Independent"
      @party_description = "You have lost hope in the American political system, " +
                           "and you can't decide which of the two major parties to support because you think they both suck ass--" +
                           "in the end, we are all doomed."
    when 60..84
      @party_affiliation = "Moderate Democrat"
      @party_description = "You recycle and you'll ride the bus instead of taking the car when it's not too inconvenient. " +
                           "You listen to NPR or jazz in the evenings while sipping on wine. Obama is a nice guy, and he's doing an okay job."
    else
      @party_affiliation = "Strong Democrat"
      @party_description = "Congratulations, you're a socialist! You want to beat the hell out of rich people because you think they're all intrinsically evil. " +
                           "And right now, you're freezing your ass off because you're living in a tent in the middle of downtown."
  end

  city = request.location.city
  state_short = request.location.state
  state = full_state_name(state_short)
  @location = city + ', ' + state_short

  # Add entry to database and render "show" template
  poll_taker = PollTaker.create( :ip_address => request.ip, :city => city, :state_short => state_short, :state => state, :score => submitted_score, :party => @party_affiliation )

  # Data used in heat map
  scores_by_state
  
  haml :show
end

get '/map' do
  @title = TITLE + " - Heatmap of the Results"
  scores_by_state
  haml :map
end

not_found do
  @title =  TITLE + " - Page Not Found"
  haml :'404'
end


private

# Sets the instance variable that holds array of states and their associated scores. 
# I put this in a separate method because it's invoked in multiple pages.
def scores_by_state
    @scores_by_state = PollTaker.aggregate( :fields => [:state, :score.avg], :order => [:state.asc] ).map do |pair|
    [pair[0], pair[1].round(1)]
  end
end

# Google Geochart requires the full state name to create the DataTable used to populate the chart.
# Unfortunately, Geocoder only returns the two-letter abbreviation for each state, which means that
# a method must be used to convert the abbreviated version to the full state name.
def full_state_name(state_short)
  case state_short
    when 'AL' then 'Alabama'
    when 'AK'	then 'Alaska'
    when 'AZ'	then 'Arizona'
    when 'AR'	then 'Arkansas'
    when 'CA'	then 'California'
    when 'CO'	then 'Colorado'
    when 'CT' then 'Connecticut'
    when 'DE' then 'Delaware'
    when 'FL' then 'Florida'
    when 'GA' then	'Georgia'
    when 'HI' then 'Hawaii'
    when 'ID' then 'Idaho'
    when 'IL'	then 'Illinois'
    when 'IN' then 'Indiana'
    when 'IA' then 'Iowa'
    when 'KS' then 'Kansas'
    when 'KY' then 'Kentucky'
    when 'LA'	then 'Louisiana'
    when 'ME' then 'Maine'
    when 'MD' then 'Maryland'
    when 'MA' then 'Massachusetts'
    when 'MI'	then 'Michigan'
    when 'MN'	then 'Minnesota'
    when 'MS'	then 'Mississippi'
    when 'MO'	then 'Missouri'
    when 'MT'	then 'Montana'
    when 'NE'	then 'Nebraska'
    when 'NV'	then 'Nevada'
    when 'NH'	then 'New Hampshire'
    when 'NJ'	then 'New Jersey'
    when 'NM' then 'New Mexico'
    when 'NY'	then 'New York'
    when 'NC'	then 'North Carolina'
    when 'ND'	then 'North Dakota'
    when 'OH'	then 'Ohio'
    when 'OK'	then 'Oklahoma'
    when 'OR'	then 'Oregon'
    when 'PA'	then 'Pennsylvania'
    when 'RI' then 'Rhode Island'
    when 'SC'	then 'South Carolina'
    when 'SD'	then 'South Dakota'
    when 'TN' then 'Tennessee'
    when 'TX'	then 'Texas'
    when 'UT'	then 'Utah'
    when 'VT'	then 'Vermont'
    when 'VA'	then 'Virginia'
    when 'WA'	then 'Washington'
    when 'WV'	then 'West Virginia'
    when 'WI'	then 'Wisconsin'
    when 'WY'	then 'Wyoming'
  end
end