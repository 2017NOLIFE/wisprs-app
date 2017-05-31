class FindGithubAccount
  def initialize(config)
    @config = config
  end
  
  def call(code)
    response = HTTP.headers(accept: 'application/json')
                   .get("#{@config.API_URL}/github_account?code=#{code}")
    puts "SSO: #{response.parse}"
    response.code == 200 ? response.parse : nil
  end
end
