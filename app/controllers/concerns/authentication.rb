module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      return Current.session if @session_resumed

      @session_resumed = true
      Current.session = find_session_by_cookie
      return unless Current.session

      if Current.session.slide!
        set_session_cookie(Current.session)
        return Current.session
      end

      cookies.delete(:session_id)
      Current.session = nil
    end

    def find_session_by_cookie
      session_id = cookies.signed[:session_id]
      Session.active.find_by(id: session_id) if session_id
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to login_path
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def start_new_session_for(user)
      now = Time.current
      user.sessions.create!(
        user_agent: request.user_agent,
        ip_address: request.remote_ip,
        expires_at: now + Session::SESSION_LENGTH,
        absolute_expires_at: now + Session::ABSOLUTE_TTL
      ).tap do |session|
        Current.session = session
        set_session_cookie(session)
      end
    end

    def terminate_session
      Current.session&.destroy
      Current.session = nil
      cookies.delete(:session_id)
    end

    def set_session_cookie(session)
      cookies.signed[:session_id] = {
        value: session.id,
        httponly: true,
        same_site: :lax,
        secure: Rails.env.production?,
        expires: session.expires_at
      }
    end
end
