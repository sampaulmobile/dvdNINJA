class AddRtIdToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :rt_id, :string, default: -1
  end
end
