class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.string :title
      t.string :studio
      t.string :rating
      t.integer :year
      t.string :genre
      t.datetime :release_date

      t.string :cover_pic_url
      t.string :rt_summary
      t.integer :critics_score, default: -1
      t.integer :users_score, default: -1

      t.timestamps
    end

    add_index :movies, :title, unique: true
  end
end
