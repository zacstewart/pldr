class CreatePhotos < ActiveRecord::Migration
  def up
    create_table :photos do |t|
      t.string  :tiny, limit: 8, null: false
      t.string  :file, null: false
    end
  end

  def down
    drop_table :photos
  end
end
