# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self
    # data: URIs are needed for any base64-encoded inline images
    policy.img_src     :self, :data
    policy.object_src  :none
    # Nonce covers importmap inline script blocks and any javascript_tag helpers
    policy.script_src  :self
    # unsafe_inline retained for styles; Bulma and Turbo may apply inline styles
    policy.style_src   :self, :unsafe_inline
    # self covers Turbo Drive / Action Cable fetch/websocket requests
    policy.connect_src :self
    # Disallow embedding this app in any frame
    policy.frame_ancestors :none
    # Lock base URI and form actions to the same origin
    policy.base_uri    :self
    policy.form_action :self
  end

  # Per-request nonces prevent replay attacks.  Importmap, javascript_tag, and
  # javascript_include_tag helpers automatically receive the nonce attribute.
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src]
end
