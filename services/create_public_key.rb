require 'http'

# Returns all the messages belonging to an account
class CreatePublicKey
  def initialize(config)
    @config = config
  end

  def call(current_account_id:, auth_token:)
    p current_account_id
    response = HTTP.auth("Bearer #{auth_token}")
                   .post("#{@config.API_URL}/public_keys/"+current_account_id)
    response.code == 200 ? response.parse : nil
  end

  private

  # def extract_key(keys)
  #   keys['data'].map do |msg|
  #     { key: msg['key'],
  #       name: msg['name'], }
  #   end
  # end
end
