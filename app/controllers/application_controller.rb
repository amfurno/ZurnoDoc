class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index
  after_action :persist_current_patient, if: -> { @patient.present? }

  rescue_from Pundit::NotAuthorizedError, with: :pundit_not_authorized

  # Controllers that use allow_unauthenticated_access must also declare:
  #   skip_after_action :verify_authorized
  #   skip_after_action :verify_policy_scoped
  # to prevent Pundit verification running with a nil user.

  private

  def pundit_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_back_or_to root_path, allow_other_host: false
  end

  def pundit_user
    Current.user
  end

  def current_patient
    return unless authenticated? && session[:current_patient_id].present?

    @current_patient ||= begin
      patient = Current.user.patients.find_by(id: session[:current_patient_id])
      session[:current_patient_id] = nil unless patient
      patient
    end
  end
  helper_method :current_patient

  def persist_current_patient
    session[:current_patient_id] = @patient.id
  end
end
