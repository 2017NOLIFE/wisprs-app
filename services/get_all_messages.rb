require 'http'

# Returns all the messages belonging to an account
class GetAllMessages
  def initialize(config)
    @config = config
  end

  def call(current_account:, auth_token:)
    response = HTTP.auth("Bearer #{auth_token}")
                   .get("#{@config.API_URL}/accounts/#{current_account['id']}/messages")
    response.code == 200 ? extract_messages(response.parse) : nil
  end

  private

  def extract_messages(messages)
    messages['data'].map do |msg|
      { id: msg['id'],
        title: msg['attributes']['title'],
        about: msg['attributes']['about'],
        status: msg['attributes']['status'],
        expire_date: msg['attributes']['expire_date'],
        body: msg['attributes']['body'],
        from_user: msg['relationships']['from']['username'],
        to_user: msg['relationships']['to']['username'] }
    end
  end
end
