class CreateDoctors < ActiveRecord::Migration[8.1]
  def change
    create_table :doctors do |t|
      t.string :name
      t.string :practice
      t.string :phone_number
      t.string :email
      t.string :fax_number
      t.string :address
      t.string :speciality

      t.timestamps
    end
  end
end
