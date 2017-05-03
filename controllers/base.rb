require 'econfig'
require 'sinatra'
require 'rack-flash'
require 'rack/ssl-enforcer'

# Secure chat based api
class WispersBase < Sinatra::Base
  extend Econfig::Shortcut

  ONE_MONTH = 2_592_000 # one month seconds
  use Rack::Session::Cookie, expire_after: ONE_MONTH

  set :views, File.expand_path('../../views', __FILE__)
  set :public_dir, File.expand_path('../../public', __FILE__)

  configure do
    Econfig.env = settings.environment.to_s
    Econfig.root = File.expand_path('..', settings.root)

    SecureDB.setup(settings.config)
  end

  configure :production do
    use Rack::SslEnforcer
  end

  before do
    @current_account = session[:current_account]
    host_url = "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    @request_url = URI.join(host_url, request.path.to_s)
  end

  get '/' do
    slim :home
  end
end
