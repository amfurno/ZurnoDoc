class MedicationsController < ApplicationController
  before_action :set_patient
  before_action :set_medication, only: %i[show edit update destroy]
  before_action :set_doctors, only: %i[new create edit update]

  def index
    @active_sort      = resolve_sort(params[:active_sort])
    @active_direction = resolve_direction(params[:active_direction])
    @past_sort        = resolve_sort(params[:past_sort])
    @past_direction   = resolve_direction(params[:past_direction])

    @active_medications = @patient.medications.active.sorted(@active_sort, @active_direction)
    @past_medications   = @patient.medications.past.sorted(@past_sort, @past_direction)
  end

  def show
  end

  def new
    @medication = @patient.medications.build
  end

  def create
    @medication = @patient.medications.build(medication_params)
    if @medication.save
      redirect_to patient_medication_path(@patient, @medication)
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @medication.update(medication_params)
      redirect_to patient_medication_path(@patient, @medication)
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @medication.destroy
    redirect_to patient_medications_path(@patient)
  end

  private

  def set_patient
    @patient = Current.user.patients.find(params[:patient_id])
  end

  def set_medication
    @medication = @patient.medications.find(params[:id])
  end

  def set_doctors
    @doctors = @patient.doctors
  end

  def resolve_sort(column)
    Medication::SORTABLE_COLUMNS.include?(column.to_s) ? column.to_s : "name"
  end

  def resolve_direction(direction)
    direction == "desc" ? "desc" : "asc"
  end

  def medication_params
    params.expect(medication: [ :name, :drug_class, :dosage, :date_started, :date_stopped, :notes, :side_effects, :doctor_id ])
  end
end
