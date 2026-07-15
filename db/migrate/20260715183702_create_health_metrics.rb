class CreateHealthMetrics < ActiveRecord::Migration[8.1]
  def change
    create_table :health_metrics do |t|
      t.references :patient, null: false, foreign_key: true
      t.string :name, null: false
      t.string :unit, null: false
      t.text :notes

      t.timestamps
    end

    add_index :health_metrics,
              "patient_id, lower(name)",
              unique: true,
              name: "index_health_metrics_on_patient_id_lower_name"
  end
end
