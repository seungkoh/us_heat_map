# Fall Project: Geo-Based Survey and Heatmap

## Summary

The final project consists of a Sinatra web app that
calculates where the survey taker lies along the political spectrum in 
respect to the two major political parties.

The survey itself is trivial, and if time had allowed, I would 
have liked to make the app robust enough to allow users to create their
own surveys.

Another important component of the app is that it captures the location of the
client in a data store using the combination of a Ruby geocoding gem (see below) and the 
DataMapper ORM (see below). For the purposes of this project, the client's IP address, 
city, and state were kept in the database. 

Lastly, the results from all survey submissions taken from all locations over time are 
used to calculate an average score per state and create a chart comparing political 
affiliation among the states.

## Gems & Tools from Course

The following gems and tools covered in this course were used for the final project:
* Ruby (of course)
* Rake
* Guard
* Bundler
* Git
* Sinatra
* Haml
* Ruby Debug
* RSpec
* Rack::Test
* Heroku

## New Gems & Tools

I also discovered some new gems and tools to help build site, which include the following:
* [Geocoder](http://www.rubygeocoder.com/) - Ruby geocoding gem
* [DataMapper](datamapper.org) - Ruby-based Object Relational Mapper (ORM) and alternative to ActiveRecord
* [Google Geochart](http://code.google.com/apis/chart/interactive/docs/gallery/geochart.html) - JavaScript library used to create heatmap chart
* SQLite3 Database - database engine used for local development

## How to Use the App

The application is hosted on [Heroku](http://usheatmap.heroku.com). Simply to go the homepage
and take the survey. When you submit the form, you will be taken to a results page that tells
you where you fit along the political spectrum, as well as a heat map at the bottom of the page.

It is also possible to view the heat map directly from the home page, where there is a link at
the bottom of the page titled "Check out the survey results."

The differences between the heatmap on the results page and the one that does not route through
the survey are a) the size of the report and b) the former takes into account a new survey
entry before rendering the map.

## Setbacks and Limitations of the Application

### Local Testing
I had to manually populate the database with seed data in order to calculate the state score
and render the chart because the IP address exposed by my ISP did not return a valid location 
from the Geocoder gem. 

### Lack of User Validation
The application does not keep track of whether or not a client has already taken the survey,
which means that anybody can essentially take the survey as many times as he or she wants. 
Consequently, a survey like this does not have any safeguards against an abusive user taking
the survey multiple times to skew the results.

### Geochart
Geochart is not as flexible as I would have liked it to be. One major problem I had with this charting
tool is that the legend pegs the endpoints to the highest and lowest data values you feed into
the chart. Consequently, instead of setting absolute values, such as 0 and 100, the legend might
have low and high values of 45 and 55, respectively. In such a case, 45 will be marked red and 55
will be marked blue, despite the fact that both scores represent an Independent/Moderate. 

Another shortcoming of the legend is that I would have liked to give the endpoints labels in place of
the numerical values--"Republican" in place of 0 and "Democrat" in place of 100.

Despite the limitations of this library, I chose to run with it because I could not find a better
alternative for Ruby if I wanted to create a heatmap of the United States (it probably would have
been much easier to create a different type of chart, such as a bar chart).

## Proxies
One thing you will notice about this application is that data from many of the states are missing.
Furthermore, since most (if not all) users of this app are located in the Seattle area, most of the
calculation will only affect Washington state. To get around this problem, I used the following proxy
servers to replicate form submissions from other areas of the country:
* http://freeproxyserver.net/
* http://www.publicproxyservers.com/proxy/list1.html

