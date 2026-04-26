class CreateMedications < ActiveRecord::Migration[8.1]
  def change
    create_table :medications do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :doctor, null: true, foreign_key: true
      t.string :name, null: false
      t.string :drug_class
      t.string :dosage
      t.date :date_started
      t.date :date_stopped
      t.text :notes
      t.text :side_effects

      t.timestamps
    end
  end
end
