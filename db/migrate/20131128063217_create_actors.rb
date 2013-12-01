class CreateActors < ActiveRecord::Migration
  def change
    create_table :actors do |t|
      t.string :first_name
      t.string :last_name
      t.string :rt_url
      t.string :pic_url

      t.timestamps
    end
  end
end
