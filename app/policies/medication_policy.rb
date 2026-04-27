# frozen_string_literal: true

class MedicationPolicy < ApplicationPolicy
  def index? = owns_parent_patient?
  def show? = owns_parent_patient?
  def create? = owns_parent_patient?
  def update? = owns_parent_patient?
  def destroy? = owns_parent_patient?
  def stop? = owns_parent_patient?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:patient).where(patients: { user: user })
    end
  end

  private

  def owns_parent_patient?
    record.patient.user == user
  end
end
