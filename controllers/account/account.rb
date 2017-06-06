# frozen_string_literal: true

require 'sinatra'
require 'econfig'

# Account related routes
class WispersBase < Sinatra::Base
  def authenticate_login(auth)
    @current_account = auth['account']
    @auth_token = auth['auth_token']
    current_session = SecureSession.new(session)
    current_session.set(:current_account, @current_account)
    current_session.set(:auth_token, @auth_token)
  end

  get '/auth/login/?' do
    @gh_url = GetApiGithubSsoUrl.new(settings.config).call
    slim :login
  end

  post '/auth/login/?' do
    credentials = LoginCredentials.call(params)

    if credentials.failure?
      flash[:error] = 'Please enter both username and password'
      redirect '/auth/login'
    end

    auth = FindAuthenticatedAccount.new(settings.config).call(credentials)

    if auth
      authenticate_login(auth)
      flash[:notice] = "Welcome back #{@current_account['username']}"
      redirect '/'
    else
      flash[:error] = 'Your username or password did not match our records'
      redirect '/account/login/'
    end
  end

  get '/auth/logout/?' do
    @current_account = nil
    SecureSession.new(session).delete(:current_account)
    flash[:notice] = 'You have logged out - please login again to use this site'
    redirect '/auth/login'
  end

  get '/github_callback/?' do
    begin
      sso_account = FindGithubAccount.new(settings.config)
                                     .call(params['code'])
      authenticate_login(sso_account)
      redirect "/account/#{@current_account['id']}/messages"
      halt
    rescue => e
      flash[:error] = 'Could not sign in using Github'
      puts "RESCUE: #{e}"
      redirect '/auth/login'
    end
  end

  get '/account/:id/?' do
    halt_if_incorrect_user(params)
    if current_account?(params)
      @key_message = GetAccountPublicKey.new(settings.config)
                                 .call(current_account_id: @current_account['id'].to_s,
                                       auth_token: @auth_token)
      @key_message = '' unless !@key_message.nil?

      slim(:account)
    else
      redirect '/auth/login'
    end
  end

  post '/account/createpublickey/?' do
    result = CreatePublicKey.new(settings.config).call(
      current_account_id: @current_account['id'].to_s,
      public_key: params[:public_key_input],
      current_account_name: @current_account['username']
    )
    flash[:error] = 'Public key fail, please input again!!!' unless result
    redirect "/account/#{@current_account['id']}"
  end
end
