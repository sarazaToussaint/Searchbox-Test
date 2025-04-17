# Be sure to restart your server when you modify this file.

# Specify a serializer for the signed and encrypted cookie jars.
# Valid options are :json, :marshal, and :hybrid.
Rails.application.config.action_dispatch.cookies_serializer = :json

# Set cookies to be secure and http-only by default
Rails.application.config.action_dispatch.cookies_same_site_protection = :lax
Rails.application.config.action_dispatch.use_cookies_with_metadata = true

# Set default cookie expiration to 1 year
Rails.application.config.session_store :cookie_store, 
                                      key: '_searchbox_session',
                                      expire_after: 1.year 