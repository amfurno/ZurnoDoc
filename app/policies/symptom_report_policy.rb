class SymptomReportPolicy < ApplicationPolicy
  def new? = owns_parent_patient?
  def create? = owns_parent_patient?

  private

  def owns_parent_patient?
    record.patient.user == user
  end
end
