# Service object to send a new message
class SendMessage
  def self.call(from_id:, to_id:, title:, about:, expire_date:, status:, body:)
    message = Message.new()

    from = Account[from_id]
    to = Account[to_id]
    message.about = about
    message.title = title
    message.from = from
    message.to = to
    message.expire_date = expire_date
    message.body = body
    message.status = status
    message.save
  end
end
