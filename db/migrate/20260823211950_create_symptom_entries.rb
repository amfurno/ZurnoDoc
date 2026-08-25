class CreateSymptomEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :symptom_entries do |t|
      t.references :symptom, null: false, foreign_key: true
      t.date :date, null: false

      t.timestamps
    end

    add_index :symptom_entries, %i[symptom_id date], unique: true
  end
end
