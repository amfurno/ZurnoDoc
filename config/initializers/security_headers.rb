# Be sure to restart your server when you modify this file.

# Merge additional security headers into Rails' default response headers.
# Rails already sets X-Content-Type-Options: nosniff and
# Referrer-Policy: strict-origin-when-cross-origin by default.
Rails.application.configure do
  config.action_dispatch.default_headers.merge!(
    # Deny all framing — this app should never be embedded in an iframe.
    # CSP frame-ancestors: none above also covers this; belt-and-suspenders.
    'X-Frame-Options' => 'DENY',

    # Restrict browser feature access. Adjust if the app ever needs camera/geo.
    'Permissions-Policy' => 'camera=(), microphone=(), geolocation=(), payment=()',

    # Prevents cross-origin windows from retaining a reference to this browsing
    # context — mitigates Spectre-style cross-origin data leak attacks.
    'Cross-Origin-Opener-Policy' => 'same-origin',

    # Prevents other origins from loading our responses via no-cors requests
    # (e.g. <img>, <script> tags from foreign pages).
    'Cross-Origin-Resource-Policy' => 'same-origin'
  )
end
