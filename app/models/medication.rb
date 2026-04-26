class Medication < ApplicationRecord
  belongs_to :patient
  belongs_to :doctor, optional: true

  validates :name, presence: true

  SORTABLE_COLUMNS = %w[name drug_class dosage date_started date_stopped doctor_name].freeze

  scope :active, -> { where(date_stopped: nil) }
  scope :past,   -> { where.not(date_stopped: nil) }

  def self.sorted(column, direction)
    col = SORTABLE_COLUMNS.include?(column.to_s) ? column.to_s : "name"
    dir = direction == "desc" ? "desc" : "asc"

    if col == "doctor_name"
      left_joins(:doctor).order(Arel.sql("doctors.name #{dir} NULLS LAST"))
    else
      order(Arel.sql("#{connection.quote_column_name(col)} #{dir}"))
    end
  end
end
