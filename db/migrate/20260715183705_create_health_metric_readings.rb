class CreateHealthMetricReadings < ActiveRecord::Migration[8.1]
  def change
    create_table :health_metric_readings do |t|
      t.references :health_metric, null: false, foreign_key: true
      t.datetime :recorded_at, null: false
      t.decimal :value, precision: 12, scale: 4, null: false
      t.text :notes

      t.timestamps
    end

    add_index :health_metric_readings,
              %i[health_metric_id recorded_at],
              name: "index_health_metric_readings_on_metric_and_recorded_at"
  end
end
