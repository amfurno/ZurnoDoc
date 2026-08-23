class SymptomsController < ApplicationController
  before_action :set_patient

  def index
    # Access is already scoped through set_patient, which gates the parent patient
    # to the current user. policy_scope is intentionally skipped here.
    skip_policy_scope
    @start_date = parse_date(params[:start_date]) || Date.current
    @symptoms = @patient.symptoms.order(Arel.sql('lower(name)'))
    @symptom_entries = month_entries(@start_date)
    @calendar_data = build_calendar_data(@symptom_entries)
  end

  def day
    authorize @patient, :show?
    @date = parse_date(params[:date]) || Date.current
    @entries = @patient.symptoms
                       .joins(:entries)
                       .where(symptom_entries: { date: @date })
                       .order(Arel.sql('lower(symptoms.name)'))
    render layout: false
  end

  private

  def set_patient
    @patient = Current.user.patients.find(params[:patient_id])
    Current.patient = @patient
  end

  def parse_date(value)
    value.present? ? Date.parse(value.to_s) : nil
  rescue ArgumentError
    nil
  end

  def month_entries(start_date)
    range = start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week
    SymptomEntry.joins(:symptom)
                .where(symptoms: { patient_id: @patient.id }, date: range)
                .includes(:symptom)
  end

  def build_calendar_data(entries)
    entries.group_by { |entry| entry.date.iso8601 }
           .transform_values { |day_entries| day_entries.map(&:symptom_id) }
  end
end
