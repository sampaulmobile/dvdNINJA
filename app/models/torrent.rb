class Torrent < ActiveRecord::Base

  belongs_to :movie

  validates :magnet_url,
            presence: true,
            uniqueness: { scope: :movie }

  def self.download(url)
    t = Torrent.create(magnet_url: url)
    t.save!

    system("#{Rails.root.to_s}/scripts/queue_magnet.sh \"#{url}\"")
  end

  def download
    system("#{Rails.root.to_s}/scripts/queue_magnet.sh \"#{self.magnet_url}\"")
  end


end
