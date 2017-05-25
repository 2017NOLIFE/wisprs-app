require 'http'

# Returns all the messages belonging to an account
class CreateMessage
  def initialize(config)
    @config = config
  end

  def call(from_id:,to_id:,title:,about:,expire_date:,status:,body:)
    response = HTTP.post("#{@config.API_URL}/accounts/#{from_id}/send_message/",
                         json: { from_id: from_id,
                                  to_id: to_id,
                                  title: title,
                                  about: about,
                                  expire_date: expire_date,
                                  status: status,
                                  body: body })
    response.code == 201 ? true : false
  end
end
