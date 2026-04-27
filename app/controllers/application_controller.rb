class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  rescue_from Pundit::NotAuthorizedError, with: :pundit_not_authorized

  private

  def pundit_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back_or_to root_path, allow_other_host: false
  end

  def pundit_user
    Current.user
  end
end
