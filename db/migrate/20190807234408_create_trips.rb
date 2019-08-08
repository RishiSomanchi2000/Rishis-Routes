class CreateTrips < ActiveRecord::Migration[6.0]
  def change
    create_table :trips do |t|
      t.string :current_location
      t.string :destination

      t.timestamps
    end
  end
end
