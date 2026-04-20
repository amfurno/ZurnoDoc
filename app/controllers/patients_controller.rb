class PatientsController < ApplicationController
  before_action :set_patient, only: %i[show edit update destroy]

  def index
    @patients = Current.user.patients
  end

  def show
  end

  def new
    @patient = Current.user.patients.build
  end

  def create
    @patient = Current.user.patients.build(patient_params)
    if @patient.save
      redirect_to @patient
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @patient.update(patient_params)
      redirect_to @patient
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @patient.destroy
    redirect_to patients_path
  end

  private

  def set_patient
    @patient = Current.user.patients.find(params[:id])
  end

  def patient_params
    params.expect(patient: [ :name ])
  end
end
