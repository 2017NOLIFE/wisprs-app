require 'sinatra'

# /api/v1/messages routes
class WispersBase < Sinatra::Base
  get '/api/v1/messages/?' do
    content_type 'application/json'

    JSON.pretty_generate(data: Message.all)
  end

  get '/api/v1/messages/:id' do
    content_type 'application/json'

    message_id = params[:id]

    message = Message.where(id: message_id).first

    if message
      JSON.pretty_generate(data: message)
    else
      error_msg = "FAILED TO GET MESSAGE: \"#{message_id}\""
      logger.info error_msg
      halt 404, error_msg
    end
  end

  post '/api/v1/messages/?' do
    content_type 'application/json'

    begin
      message_info = JsonRequestBody.parse_symbolize(request.body.read)
      new_message = SendMessage.call(message_info)
    rescue => e
      error_msg = "FAILED to create a new message: #{e.inspect}"
      logger.info error_msg
      halt 400, error_msg
    end

    status 201
    headers('Location' => [@request_url.to_s, new_message.id].join('/'))
  end
end
