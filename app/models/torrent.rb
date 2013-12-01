class Torrent < ActiveRecord::Base

  belongs_to :movie

  validates :magnet_url,
            presence: true,
            uniqueness: { scope: :movie }

  def self.download(url)
    system("/Users/sampaul/Downloads/Torrents/queue_magnet.sh \"#{url}\"")
  end

  def download
    Torrent.download(self.magnet_url)
  end


end
