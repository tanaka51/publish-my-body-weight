class CreateWeightResults < ActiveRecord::Migration
  def change
    create_table :weight_results do |t|
      t.string :weight, null: false
      t.string :body_fat_percentage
      t.string :bmi

      t.datetime :created_at, null: false
    end
  end
end
