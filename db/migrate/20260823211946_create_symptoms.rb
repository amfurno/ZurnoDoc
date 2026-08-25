class CreateSymptoms < ActiveRecord::Migration[8.1]
  def change
    create_table :symptoms do |t|
      t.references :patient, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end

    add_index :symptoms,
              'patient_id, lower(name)',
              unique: true,
              name: 'index_symptoms_on_patient_id_lower_name'
  end
end
