require 'http'

# Returns all the messages belonging to an account
class CreatePublicKey
  def initialize(config)
    @config = config
  end

  def call(current_account_id:,public_key:,current_account_name:)
    response = HTTP.post("#{@config.API_URL}/public_keys/",
                         json: { owner_id: current_account_id,
                                 key: public_key,
                                 name: current_account_name })
    response.code == 201 ? true : false
  end
end
