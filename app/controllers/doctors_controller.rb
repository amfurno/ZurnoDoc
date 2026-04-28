class DoctorsController < ApplicationController
  before_action :set_patient
  before_action :set_doctor, only: %i[show edit update destroy]

  def index
    # Access is already scoped through set_patient, which gates the parent patient
    # to the current user. policy_scope is intentionally skipped here.
    skip_policy_scope
    @doctors = @patient.doctors
  end

  def show
    authorize @doctor
  end

  def new
    @doctor = @patient.doctors.build
    authorize @doctor
  end

  def create
    @doctor = @patient.doctors.build(doctor_params)
    authorize @doctor
    if @doctor.save
      redirect_to patient_doctor_path(@patient, @doctor)
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @doctor
  end

  def update
    authorize @doctor
    if @doctor.update(doctor_params)
      redirect_to patient_doctor_path(@patient, @doctor)
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @doctor
    @doctor.destroy
    redirect_to patient_doctors_path(@patient)
  end

  private

  def set_patient
    @patient = Current.user.patients.find(params[:patient_id])
  end

  def set_doctor
    @doctor = @patient.doctors.find(params[:id])
  end

  def doctor_params
    params.expect(doctor: [ :name, :practice, :speciality, :email, :phone_number, :fax_number, :address ])
  end
end
