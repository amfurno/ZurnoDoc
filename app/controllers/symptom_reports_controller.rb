class SymptomReportsController < ApplicationController
  # No index action — skip inherited index-only/index-except Pundit callbacks
  # and re-declare verify_authorized unconditionally for this controller.
  skip_after_action :verify_policy_scoped
  skip_after_action :verify_authorized
  after_action :verify_authorized

  before_action :set_patient

  def new
    @symptom_report = SymptomReport.new(patient: @patient, date: Date.current)
    authorize @symptom_report
    @symptoms = @patient.symptoms.order(Arel.sql('lower(name)'))
  end

  def create
    @symptom_report = SymptomReport.new(symptom_report_params.merge(patient: @patient))
    authorize @symptom_report
    if @symptom_report.save
      redirect_to patient_symptoms_path(@patient, start_date: @symptom_report.date.beginning_of_month)
    else
      @symptoms = @patient.symptoms.order(Arel.sql('lower(name)'))
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_patient
    @patient = Current.user.patients.find(params[:patient_id])
    Current.patient = @patient
  end

  def symptom_report_params
    params.expect(symptom_report: [:date, :new_symptoms_text, { symptom_ids: [] }])
  end
end
