# Service object to create a new public key for an account
class CreatePublicKeyForAccount
  def self.call(owner_id:, key:, owner_name:)
    public_key = Public_key.new(
      key: key, name: owner_name
    )
    owner = Account[owner_id]
    public_key.owner = owner
    public_key.save
  end
end
