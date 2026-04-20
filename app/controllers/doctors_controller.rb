class DoctorsController < ApplicationController
  before_action :set_patient
  before_action :set_doctor, only: %i[show edit update destroy]

  def index
    @doctors = @patient.doctors
  end

  def show
  end

  def new
    @doctor = @patient.doctors.build
  end

  def create
    @doctor = @patient.doctors.build(doctor_params)
    if @doctor.save
      redirect_to patient_doctor_path(@patient, @doctor)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @doctor.update(doctor_params)
      redirect_to patient_doctor_path(@patient, @doctor)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
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
