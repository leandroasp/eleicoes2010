# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_eleicoes2010_session',
  :secret      => '6c3341ba25ce93494a2c2619e5a241eca87214c1958be7a88f82635b0171c5b6a55be030ab04cf5fd76938d4cc5210980db12ff82bc49573f46a729e24a14bb0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
