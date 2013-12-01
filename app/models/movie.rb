class Movie < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  require 'uri'
  require 'open-uri'
  require 'zip/zipfilesystem'
  require 'nokogiri'
  require 'logger'

  has_many :castings
  has_many :actors, through: :castings
  has_many :torrents

  validates_uniqueness_of :title

  @log_file = nil

  def self.load_movies(url = "http://www.hometheaterinfo.com/download/new_csv.zip",
                       fname = "new_csv.txt")
    @log_file = Logger.new('import_log.txt')

    start = Time.now
    @log_file.debug "LOAD MOVIES started at #{start}"

    self.download_csv(url, fname)
    @log_file.debug "Downloaded movie file in #{Time.now - start}"

    self.parse_file(fname)
    @log_file.debug "Finished LOADING MOVIES in #{Time.now - start}"

    delete(fname)
    delete("new_csv.zip")

  end

  def self.download_csv(url, fname)
    File.open('new_csv.zip', "wb") do |file|
      file.write open(url).read
      file.close
    end

    Zip::ZipFile.open("new_csv.zip") do |zipfile|
      zipfile.each do |file|
        if file.to_s == fname
          zipfile.extract(file, fname) { true }
        end
      end
    end
  end

  def self.parse_file(fname)
    f = File.open(fname).each do |line|
      allowed = [0, 1, 7, 8, 9, 12]
      cols = ["title", "studio", "rating", "year", "genre", "release_date"]

      entry = {}
      c = 0
      line.split('|').each_with_index do |s, i|
        if allowed.include? i
          entry[cols[c]] = s
          c += 1
        end
      end

      m = Movie.new(entry)
      if m.save
        @log_file.debug "Parsed #{m.title}"

        m.get_rt_info
        m.get_torrents

        rt_txt = "No RT data"
        if m['rt_summary'] != "" then rt_txt = "RT reviews" end 
        if m['critics_score'] != -1 then rt_txt += " (w/ critic score)" end

        log_entry = "Added #{m.title} with #{rt_txt} and #{m.torrents.count} torrents."
        @log_file.debug log_entry 
      end
    end

    f.close
  end

  def self.get_movie_data(title)
    clip = title.gsub(/\s+/,'+').gsub(/\#/,'%23').gsub(/\*/,'').gsub(/@/,'')
    clip = URI.escape(clip)

    url = "http://www.rottentomatoes.com/search/?search=#{clip}"
    begin
      page = Nokogiri::HTML(open(url))

      page_title = page.css('title').text.downcase
      return page unless page_title.include? "search results"

      first_link = page.css('span[class="movieposter"] a')[0]["href"]
      Nokogiri::HTML(open("http://www.rottentomatoes.com#{first_link}"))
    rescue Exception => e
      puts "ERROR - getting RT page/data for #{title} - #{e}"
    end
  end

  def get_rt_info
    page = Movie.get_movie_data(self.title.gsub(/\(.*\)/, ''))

    if !page then return end

    begin
      self.update_column(:cover_pic_url, page.css('meta[property="og:image"]')[0]["content"])

      critics_score = page.css('meta[name="twitter:data1"]')[0]["content"]
      self.update_column(:critics_score, critics_score.include?("%") ? critics_score[/.*%/][0..-2] : -1)

      users_score = page.css('meta[name="twitter:data2"]')[0]["content"]
      self.update_column(:users_score, users_score.include?("%") ? users_score[/.*%/][0..-2] : -1)

      rt_summary = page.css('meta[property="og:description"]')[0]["content"]
      self.update_column(:rt_summary, rt_summary)

      page.css('div[id="cast-info"] li')[0..6].each do |a_div|

        first = a_div.css('img')[0]["alt"].split(' ')[0]
        last = a_div.css('img')[0]["alt"].split(' ')[1..-1].join(' ')

        aa = Actor.find_by_first_name_and_last_name(first, last)
        if aa == nil
          aa = Actor.new(first_name: first,
                         last_name: last,
                         rt_url: "http://www.rottentomatoes.com#{a_div.css('a')[0]['href']}",
                         pic_url: a_div.css('img')[0]["src"])

          if !aa.save then next end
          #@log_file.debug "Added actor #{first} #{last}"

          if Casting.create(actor_id: aa.id, movie_id: self.id)
            #@log_file.debug "Added actor #{first} #{last} to #{self.title}"
          end
        end
      end
    rescue Exception => e
      puts "ERROR - parsing RT page/data for #{title} - #{e}"
    end
  end

  def get_torrents
    title = self.title

    clip = title.gsub(/\s+/,'%20')
    clip = title.gsub(/\*/,'').gsub(/@/,'')
    clip = URI.escape(clip)

    url = "http://thepiratebay.sx/search/#{clip}/0/7/200"
    begin
      page = Nokogiri::HTML(open(url))
    
      links = page.css('div[id="main-content"]')
      titles = links.css('div[class="detName"] a')
      magnets = links.css('a[title="Download this torrent using magnet"]')
    rescue
      return
    end
    
    begin
      torrents = []
      num = titles.length > 7 ? 7 : titles.length
      num.times do |i|
        torrents << { "torrent_title" => titles[i].text, "magnet" => magnets[i]['href'] }
        tt = self.torrents.build(title: titles[i].text, magnet_url: magnets[i]['href'])
        tt.save
      end
    rescue Exception => e
      puts "ERROR - Invalid torrent parse for #{self.title}: #{e}"
    end
  end

  def self.update_rt_dvds
    @log_file ||= Logger.new('import_log.txt')

    start = Time.now
    @log_file.debug "Update RT DVDs started at #{start}"
    @log_file.debug ""

    root_url = "http://api.rottentomatoes.com/api/public/v1.0"
    api_key = "ydk8dpdpnubmb33ynvjywqyk"
    dvd_lists_url = "#{root_url}/lists/dvds.json?apikey=#{api_key}"

    JSON.load(open(dvd_lists_url))['links'].each do |k,v|
      JSON.load(open("#{root_url}/lists/dvds/#{k}.json?apikey=#{api_key}"))['movies'].each do |movie|
        m = Movie.find_or_create_by(rt_id: movie['id'])

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

        if m.save
          @log_file.debug "Created/Updated #{m['title']}"
          puts "Created/Updated #{m['title']}"
        end
      end
    end

    @log_file.debug "Finished updating RT DVDs in #{Time.now - start}"
  end

  def self.queue_magnets(title)
    #clip = title.gsub(/\s+/,'%20').gsub(/\*/,'').gsub(/@/,'')
    clip = URI.escape(title)
    url = "http://thepiratebay.sx/search/#{clip}/0/7/200"

    begin
      page = Nokogiri::HTML(open(url))

      links = page.css('div[id="main-content"]')
      titles = links.css('div[class="detName"] a')
      magnets = links.css('a[title="Download this torrent using magnet"]')
        
      magnets[0..2].each do |m|
        system("/Users/sampaul/Downloads/Torrents/queue_magnet.sh \"#{m['href']}\"")
      end
    rescue
      return
    end
  
    titles[0..2].map {|t| t.text}
  end

end
