# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
  

set :output, "/Users/sampaul/Development/SBP/dvdNINJA/cron_log.log"

every 3.hours do
    command 'rvm use 2.0.0@dvdNINJA'
    runner "Movie.torrent_rt_dvds", environment: "development"
end

every 12.hours do
    command 'rvm use 2.0.0@dvdNINJA'
    runner "Movie.update_rt_dvds", environment: "development"
end

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
