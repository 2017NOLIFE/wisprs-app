require 'sequel'

Sequel.seed(:development) do
	def run
		puts 'Seeding accounts, public_key, messages'
		create_accounts
		create_public_key
		create_messages
	end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ALL_ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
ALL_PUBLIC_KEY_INFO = YAML.load_file("#{DIR}/public_key_seed.yml")
ALL_MESSAGES_INFO = YAML.load_file("#{DIR}/message_seed.yml")

def create_accounts
	ALL_ACCOUNTS_INFO.each do |account_info|
    	CreateAccount.call(account_info)
	end
end

def create_public_key
	public_key = ALL_PUBLIC_KEY_INFO.each
  	loop do
    	public_key_item = public_key.next
    	CreatePublicKeyForAccount.call(owner_id: public_key_item[:id], key: public_key_item[:key],
                               owner_name: public_key_item[:name])
  	end

end

def create_messages
	messages = ALL_MESSAGES_INFO.each
  	loop do
    	messages_item = messages.next
    	SendMessage.call(from_id: messages_item[:from_id], to_id:messages_item[:to_id],
   			title:messages_item[:title_secure], about:messages_item[:about_secure], 
   			expire_date:messages_item[:expire_date], status:messages_item[:status_secure], body:messages_item[:body_secure])
  	end
end
