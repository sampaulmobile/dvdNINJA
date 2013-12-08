class AddRtTorrentedToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :rt_torrented, :boolean, default: false
    add_column :movies, :rt_torrents, :string, default: ""
  end
end
