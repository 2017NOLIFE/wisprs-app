require 'sinatra'

# /api/v1/accounts routes only
class WispersBase < Sinatra::Base
  get '/api/v1/accounts/:id' do
    content_type 'application/json'

    id = params[:id]
    account = Account.where(id: id).first

    if account
      sent_messages = account.sent_messages
      JSON.pretty_generate(data: account, relationships: sent_messages)
    else
      halt 401, "ACCOUNT NOT VALID: #{id}"
    end
  end

  post '/api/v1/accounts/?' do
    begin
      registration_info = JsonRequestBody.parse_symbolize(request.body.read)
      new_account = CreateAccount.call(registration_info)
    rescue => e
      logger.info "FAILED to create new account: #{e.inspect}"
      halt 400
    end

    new_location = URI.join(@request_url.to_s + '/', new_account.username).to_s

    status 201
    headers('Location' => new_location)
  end

  #----------------------

  get '/account/login/?' do
    slim :login
  end

  post '/account/login/?' do
    puts "CREDENTIALS: #{params[:username]} - #{params[:password]}"
    @current_account = FindAuthenticatedAccount.new(settings.config).call(
      username: params[:username], password: params[:password]
    )

    if @current_account
      session[:current_account] = @current_account
      flash[:error] = "Welcome back #{@current_account['username']}"
      slim :home
    else
      flash[:error] = 'Your username or password did not match our records'
      slim :login
    end
  end

  get '/account/logout/?' do
    @current_account = nil
    session[:current_account] = nil
    flash[:notice] = 'You have logged out - please login again to use this site'
    slim :login
  end

  get '/account/register/?' do
    slim(:register)
  end

  get '/account/:username/?' do
    if @current_account && @current_account['username'] == params[:username]
      slim(:account)
    else
      redirect '/account/login'
    end
  end
end
