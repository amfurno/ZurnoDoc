# frozen_string_literal: true

class PatientPolicy < ApplicationPolicy
  def index? = true

  def show? = owns_patient?
  def create? = true
  def update? = owns_patient?
  def destroy? = owns_patient?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(user: user)
    end
  end

  private

  def owns_patient?
    record.user == user
  end
end
