require 'sinatra'

# Base class for Whispers Web Application
class WispersBase < Sinatra::Base
  get '/account/:id/messages/?' do
    if current_account?(params)
      @messages = GetAllMessages.new(settings.config)
                                .call(current_account: @current_account,
                                      auth_token: @auth_token)
    end

    @messages ? slim(:messages_all) : redirect('/auth/login')
  end

  get '/account/:id/messages/:message_id/?' do
    if current_account?(params)
      @message = GetMessageDetails.new(settings.config)
                                  .call(message_id: params[:message_id],
                                        auth_token: @auth_token)
      if @message
        slim(:message)
      else
        flash[:error] = 'We cannot find this message in your account'
        redirect "/account/#{params[:id]}/messages"
      end
    else
      redirect '/auth/login'
    end
  end

  get '/account/:id/new_message/' do
    slim(:new_message)
  end

  post '/account/:id/new_message/?' do
    result = CreateMessage.new(settings.config).call(
      from_id: @current_account['id'].to_s,
      to_id: '0',
      receiver_name: params[:receiver_input],
      title: params[:title_input],
      about: params[:about_input],
      expire_date: params[:expire_input],
      status: 'UNREAD',
      body: params[:content_input]
    )
    flash[:notice] = 'Public key fail, please Input Again' unless result
    redirect "/account/#{params[:id]}/messages"
  end
end
