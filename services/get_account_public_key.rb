require 'http'

# Returns all the messages belonging to an account
class GetAccountPublicKey
  def initialize(config)
    @config = config
  end

  def call(current_account_id:, auth_token:)
    response = HTTP.auth("Bearer #{auth_token}")
                   .get("#{@config.API_URL}/accounts/#{current_account_id}/public_keys")
    response.code == 200 ? response.parse : nil
  end
end
