require 'econfig'
require 'sinatra'
require 'rack-flash'
require 'rack/ssl-enforcer'
require 'rack/session/redis'

# Secure chat based app
class WispersBase < Sinatra::Base
  extend Econfig::Shortcut

  ONE_MONTH = 2_592_000 # one month seconds

  set :views, File.expand_path('../../views', __FILE__)
  set :public_dir, File.expand_path('../../public', __FILE__)

  configure :production do
    use Rack::SslEnforcer
  end

  configure do
    Econfig.env = settings.environment.to_s
    Econfig.root = File.expand_path('..', settings.root)

    SecureMessage.setup(settings.config)
    SecureSession.setup(settings.config)
  end

  # use Rack::Session::Cookie, expire_after: ONE_MONTH, secret: SecureSession.secret
  # use Rack::Session::Pool, expire_after: ONE_MONTH
  use Rack::Session::Redis, expire_after: ONE_MONTH, redis_server: settings.config.REDIS_URL

  use Rack::Flash

  def current_account?(params)
    @current_account && @current_account['username'] == params[:username]
  end

  before do
    @current_account = SecureSession.new(session).get(:current_account)
  end

  get '/' do
    slim :home
  end
end
