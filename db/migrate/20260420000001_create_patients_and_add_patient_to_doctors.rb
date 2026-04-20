class CreatePatientsAndAddPatientToDoctors < ActiveRecord::Migration[8.1]
  def change
    create_table :patients do |t|
      t.string :name, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    # Remove any existing doctor rows before adding the null: false FK constraint
    reversible do |dir|
      dir.up { execute "DELETE FROM doctors" }
    end

    add_reference :doctors, :patient, null: false, foreign_key: true
  end
end
