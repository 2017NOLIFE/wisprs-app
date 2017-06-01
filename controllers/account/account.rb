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

  get '/account/login/?' do
    @gh_url = GetApiGithubSsoUrl.new(settings.config).call
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

  get '/account/:id/?' do
    halt_if_incorrect_user(params)
    if current_account?(params)
      @key_message = GetPublicKey.new(settings.config)
                                  .call(current_account_id: @current_account['id'].to_s,
                                        auth_token: @auth_token)
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
      redirect "/account/#{@current_account['id']}"
    else
      flash[:notice] = 'Public Key Fail, Please Input Again'
      redirect "/account/#{@current_account['id']}"
    end
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
      redirect 'account/login'
    end
  end
end
