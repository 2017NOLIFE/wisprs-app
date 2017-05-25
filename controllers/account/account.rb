# frozen_string_literal: true

require 'sinatra'

# Account related routes
class WispersBase < Sinatra::Base
  def authenticate_login(auth)
    puts "Auth: #{auth}"
    @current_account = auth['account']
    @auth_token = auth['auth_token']
    current_session = SecureSession.new(session)
    current_session.set(:current_account, @current_account)
    current_session.set(:auth_token, @auth_token)
  end

  get '/account/login/?' do
    slim :login
  end

  post '/account/login/?' do
    auth = FindAuthenticatedAccount.new(settings.config).call(
      username: params[:username], password: params[:password]
    )

    if auth
      authenticate_login(auth)
      flash[:notice] = "Welcome back #{@current_account['username']}"
      redirect '/'
    else
      flash[:error] = 'Your username or password did not match our records'
      redirect '/account/login/'
    end
  end

  get '/account/logout/?' do
    @current_account = nil
    SecureSession.new(session).delete(:current_account)
    flash[:notice] = 'You have logged out - please login again to use this site'
    slim :login
  end

  get '/account/register/?' do
    slim(:register)
  end

  get '/account/:username/?' do
    halt_if_incorrect_user(params)
    if current_account?(params)
      @key_message = GetPublicKey.new(settings.config)
                                  .call(current_account_id: @current_account['id'].to_s,
                                        auth_token: @auth_token)
      p '-------????'
      p @key_message
      if @key_message != nil
        slim(:account)
      else
        @key_message = ''
        slim(:account)
      end
    else
      redirect '/login'
    end 
  end

  post '/account/createpublickey/?' do
    result = CreatePublicKey.new(settings.config).call(
      current_account_id: @current_account['id'].to_s,
      public_key: params[:public_key_input],
      current_account_name: @current_account['username']
    )
    if result
      redirect '/'
    else
      flash[:notice] = 'Public Key Faili, Please Input Again'
      redirect '/'
    end
  end


end
