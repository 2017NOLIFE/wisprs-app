require 'json'
require 'base64'
require 'sequel'

require_relative '../lib/secure_db'

# Holds a Public key's Information
class Public_key < Sequel::Model
  plugin :uuid, field: :id
  many_to_one :owner, class: :Account  #key: :owner_id

  plugin :timestamps, update_on_create: true
	plugin :association_dependencies, owner: :destroy

  # set_allowed_columns :name, :key

  # encrypt field data functions

  # decrypt field data functions

  def to_json(options = {})
    JSON({
            type:  'public_key',
            id: id,
            attributes: {
              name: name,
              key: key,
              owner: owner
           }
         },
         options)
  end
end
