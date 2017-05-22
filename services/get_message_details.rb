require 'http'

# Returns the details of a message
class GetMessageDetails
  def initialize(config)
    @config = config
  end

  def call(message_id:, auth_token:)
    response = HTTP.auth("Bearer #{auth_token}")
                   .get("#{@config.API_URL}/messages/#{message_id}")
    response.code == 200 ? extract_message_details(response.parse) : nil
  end

  private

  def extract_message_details(message_data)
    { 'id' => message_data['id'] }
      .merge(message_data['attributes'])
      .merge(message_data['relationships'])
  end
end
