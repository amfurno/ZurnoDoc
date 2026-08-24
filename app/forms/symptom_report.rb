class SymptomReport
  include ActiveModel::Model

  attr_accessor :patient, :new_symptoms_text
  attr_reader :date
  attr_writer :symptom_ids

  validates :patient, presence: true
  validates :date, presence: true

  def date=(value)
    @date = value.is_a?(String) ? Date.parse(value) : value
  rescue ArgumentError
    @date = nil
  end

  def symptom_ids
    Array(@symptom_ids).compact_blank
  end

  def save # rubocop:disable Naming/PredicateMethod -- mirrors ActiveRecord::Base#save
    return false unless valid?

    ActiveRecord::Base.transaction do
      target_symptoms.each { |symptom| symptom.entries.find_or_create_by!(date: date) }
    end
    true
  end

  private

  def target_symptoms
    existing_symptoms + new_symptoms
  end

  def existing_symptoms
    patient.symptoms.where(id: symptom_ids)
  end

  def new_symptoms
    parsed_new_symptom_names.map { |name| find_or_create_symptom(name) }
  end

  # Reuses an existing symptom regardless of case instead of creating a duplicate.
  def find_or_create_symptom(name)
    patient.symptoms.where('lower(name) = ?', name.downcase).first || patient.symptoms.create!(name: name)
  end

  def parsed_new_symptom_names
    new_symptoms_text.to_s.split("\n").map(&:strip).compact_blank.uniq(&:downcase)
  end
end
