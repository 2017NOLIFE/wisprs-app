# Get the github sso url with client id
require 'econfig'
require 'http'

class GetApiGithubSsoUrl
  def initialize(config)
    @config = config
  end

  def call
    HTTP.get("#{@config.API_URL}/github_sso_url")
        .parse['url']
  end
end
