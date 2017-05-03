require 'json'
require 'base64'
require 'sequel'

require_relative '../lib/secure_db'

# Holds an Account's Information
class Account < Sequel::Model
	set_allowed_columns :username, :email

	plugin :uuid, field: :id
	one_to_one :public_key, class: :Public_key, key: :owner_id
	one_to_many :sent_messages, class: :Message, key: :from_id
	one_to_many :received_messages, class: :Message, key: :to_id

	plugin :timestamps, update_on_create: true
	plugin :association_dependencies, public_key: :destroy
	plugin :association_dependencies, sent_messages: :destroy
	plugin :association_dependencies, received_messages: :destroy


	# encrypt field data functions


	def password=(new_password)
		new_salt = SecureDB.new_salt
    hashed = SecureDB.hash_password(new_salt, new_password)
    self.salt = new_salt
    self.password_hash = hashed
	end

	# decrypt field data functions


# Json string

	def to_json(options = {})
    JSON({
						type: 'account',
            id: id,
           	attributes: {
              username: username,
              email: email,
              salt: salt
						}
         },
         options)
	end

	def password?(try_password)
    try_hashed = SecureDB.hash_password(salt, try_password)
    try_hashed == password_hash
  end

end
