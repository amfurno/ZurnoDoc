class HealthMetricReadingPolicy < ApplicationPolicy
  def create? = owns_parent_metric?
  def update? = owns_parent_metric?
  def destroy? = owns_parent_metric?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(health_metric: :patient).where(patients: { user: user })
    end
  end

  private

  def owns_parent_metric?
    record.health_metric.patient.user == user
  end
end
