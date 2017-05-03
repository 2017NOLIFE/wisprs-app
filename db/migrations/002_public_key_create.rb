require 'sequel'

Sequel.migration do
  change do
    create_table(:public_keys) do
      String :id, type: :uuid, primary_key: true
      foreign_key :owner_id, :accounts

      String :name, null: false
      String :key, null: false, unique: true

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
