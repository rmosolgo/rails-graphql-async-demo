class CreateCards < ActiveRecord::Migration[7.0]
  def change
    create_table :cards do |t|
      t.string :set
      t.string :name
      t.string :mana_cost
      t.float :cmc

      t.timestamps
    end
  end
end
