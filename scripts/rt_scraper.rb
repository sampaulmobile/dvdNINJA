require 'open-uri'
require 'json'


root_url = "http://api.rottentomatoes.com/api/public/v1.0"
api_key = "ydk8dpdpnubmb33ynvjywqyk"
dvd_lists_url = "#{root_url}/lists/dvds.json?apikey=#{api_key}"

JSON.load(open(dvd_lists_url))['links'].each do |k,v|

  JSON.load(open("#{root_url}/lists/dvds/#{k}.json?apikey=#{api_key}"))['movies'].each do |movie|
    #m = Movie.find_or_create_by(rt_id: movie['id'])

    m = {}
    m['rt_id'] = movie['id']
    m['title'] = movie['title']
    m['genre'] = movie['genres']
    m['rating'] = movie['mpaa_rating']
    #m['duration'] = movie['runtime']
    m['rt_summary'] = movie['critics_concensus']
    release_dates = movie['release_dates']
    m['release_date'] = release_dates['dvd']
    ratings = movie['ratings']
    m['critics_score'] = ratings['critics_score']
    m['users_score'] = ratings['audience_score']
    posters = movie['posters']
    m['cover_pic_url'] = posters['profile']

    puts m
    if m.save
      puts "Created/Updated #{m['title']}"
    end
  end
end
