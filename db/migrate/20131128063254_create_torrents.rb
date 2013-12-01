class CreateTorrents < ActiveRecord::Migration
  def change
    create_table :torrents do |t|
      t.integer :movie_id
      t.string :title
      t.string :magnet_url

      t.timestamps
    end
  end
end
