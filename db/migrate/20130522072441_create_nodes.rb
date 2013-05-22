class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string :name
      t.references :parent
      t.integer :lft
      t.integer :rgt

      t.timestamps
    end
    add_index :nodes, :parent_id
  end
end
