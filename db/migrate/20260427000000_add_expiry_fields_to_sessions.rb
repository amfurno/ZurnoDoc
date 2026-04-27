class AddExpiryFieldsToSessions < ActiveRecord::Migration[8.1]
  SLIDING_WINDOW = 10.minutes
  ABSOLUTE_TTL = 14.days

  class MigrationSession < ApplicationRecord
    self.table_name = :sessions
  end

  def up
    add_column :sessions, :expires_at, :datetime
    add_column :sessions, :absolute_expires_at, :datetime

    now = Time.current
    MigrationSession.reset_column_information
    MigrationSession.update_all(
      expires_at: now + SLIDING_WINDOW,
      absolute_expires_at: now + ABSOLUTE_TTL
    )

    change_column_null :sessions, :expires_at, false
    change_column_null :sessions, :absolute_expires_at, false

    add_index :sessions, :expires_at
    add_index :sessions, :absolute_expires_at
  end

  def down
    remove_index :sessions, :absolute_expires_at
    remove_index :sessions, :expires_at
    remove_column :sessions, :absolute_expires_at
    remove_column :sessions, :expires_at
  end
end
