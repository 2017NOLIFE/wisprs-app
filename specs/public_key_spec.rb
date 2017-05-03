require_relative './spec_helper'

describe 'Testing Public key resource routes' do
  before do
    Public_key.dataset.destroy
    Message.dataset.destroy
    Account.dataset.destroy
    @account = CreateAccount.call(
      username: 'test.name',
      password: 'mypass',
      email: 'test@email.com'
    )
  end

  describe 'Creating new public key' do
    before do
      public_key_data = {
        owner_id: @account.id,
        name: 'my_public_key',
        key: 'my_key'
      }
      @req_body = public_key_data.to_json
    end
    it 'HAPPY: should create a new unique public key' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post '/api/v1/public_keys/', @req_body, req_header
      _(last_response.status).must_equal 201
      _(last_response.location).must_match(%r{http://})
    end

    it 'SAD: should not create duplicate public keys (key should be unique)' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post '/api/v1/public_keys/', @req_body, req_header
      post '/api/v1/public_keys/', @req_body, req_header
      _(last_response.status).must_equal 400
      _(last_response.location).must_be_nil
    end
  end

  describe 'Finding existing public keys' do
    before do
      @new_public_key = CreatePublicKeyForAccount.call(
        owner_id: @account.id,
        name: 'my_public_key',
        key: 'my_key'
      )
    end
    it 'HAPPY: should find an existing public key' do
      get "/api/v1/public_keys/#{@new_public_key.id}"
      _(last_response.status).must_equal 200
      results = JSON.parse(last_response.body)
      _(results['data']['id']).must_equal @new_public_key.id
    end

    it 'SAD: should not find existent public key' do
      get "/api/v1/public_keys/#{random_str(10)}"
      _(last_response.status).must_equal 404
    end
  end
end