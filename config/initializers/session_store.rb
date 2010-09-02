# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_steamcannon_session',
  :secret      => '62d2e8425f8eb1625fc05b0e83d38fea59a847222ec280de311ffb33b898dd7289c696468ea81714ba7e5377169d46c08403ed7747615c8cf91bf6b7b7efddbf'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
