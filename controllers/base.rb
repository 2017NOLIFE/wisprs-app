# frozen_string_literal: true

require 'econfig'
require 'sinatra'
require 'slim/include'
require 'rack-flash'
require 'rack/session/redis'
require 'rack/flash/test'

# Base class for Secure chat Web Application
class WispersBase < Sinatra::Base
  extend Econfig::Shortcut

  enable :logging
  set :views, File.expand_path('../../views', __FILE__)
  set :public_dir, File.expand_path('../../public', __FILE__)

  configure do
    Econfig.env = settings.environment.to_s
    Econfig.root = File.expand_path('..', settings.root)

    SecureMessage.setup(settings.config)
    SecureSession.setup(settings.config)
  end

  use Rack::Flash

  def current_account?(params)
    @current_account && @current_account['id'].to_i == params[:id].to_i
  end

  def halt_if_incorrect_user(params)
    return true if current_account?(params)
    flash[:error] = 'You used the wrong account for this request'
    redirect '/auth/login'
    halt
  end

  before do
    @current_account = SecureSession.new(session).get(:current_account)
    @auth_token = SecureSession.new(session).get(:auth_token)
  end

  get '/' do
    slim :home
  end
end

# require 'openssl'
# require 'base64'
# string = 'Hello World!';
# public_key_file = Dir.pwd+'/controllers/saavizworld.pem';
#     public_key = OpenSSL::PKey::RSA.new(File.read(public_key_file))
#     puts public_key;
