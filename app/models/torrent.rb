class Torrent < ActiveRecord::Base

  belongs_to :movie

  validates :magnet_url,
            presence: true,
            uniqueness: { scope: :movie }

end
