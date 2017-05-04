require 'econfig'
require 'sinatra'
require 'rack-flash'
require 'rack/ssl-enforcer'

# Secure chat based api
class WispersBase < Sinatra::Base
  extend Econfig::Shortcut

  ONE_MONTH = 2_592_000 # one month seconds

  configure :production do
    use Rack::SslEnforcer
  end

  use Rack::Session::Cookie, expire_after: ONE_MONTH
  use Rack::Flash

  set :views, File.expand_path('../../views', __FILE__)
  set :public_dir, File.expand_path('../../public', __FILE__)

  configure do
    Econfig.env = settings.environment.to_s
    Econfig.root = File.expand_path('..', settings.root)
  end

  before do
    @current_account = session[:current_account]
  end

  get '/' do
    slim :home
  end
end
