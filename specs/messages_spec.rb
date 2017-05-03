require_relative './spec_helper'

describe 'Testing Message resource routes' do
  before do
    Public_key.dataset.destroy
    Message.dataset.destroy
    Account.dataset.destroy
    @from_account = CreateAccount.call(
      username: 'sender',
      password: 'mypass',
      email: 'sender@email.com'
    )
    @to_account = CreateAccount.call(
      username: 'receiver',
      password: 'mypass',
      email: 'receiver@email.com'
    )
  end

  describe 'Create a new message' do
    before do
      message_data = {
        from_id: @from_account.id,
        to_id: @to_account.id,
        title: 'Hello',
        about: 'All about greeting',
        expire_date: 'Test',
        status: 'NO',
        body: 'Hello everyone'
      }
      @req_body = message_data.to_json
    end
    it 'Happy: should create new message in db' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post '/api/v1/messages/', @req_body, req_header
      _(last_response.status).must_equal 201
      _(last_response.location).must_match(%r{http://})
    end

    it 'SAD: should not add a message for non-existant variable' do
      message_data = {
        from_id: @from_account.id,
        to_id: @to_account.id,
        body: 'Hello everyone'
      }
      @req_body = message_data.to_json
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post '/api/v1/messages/', @req_body, req_header
      _(last_response.status).must_equal 400
      _(last_response.location).must_be_nil
    end
  end

  describe 'Getting messages' do
    before do
      @new_message = SendMessage.call(
        from_id: @from_account.id,
        to_id: @to_account.id,
        title: 'Hello',
        about: 'All about greeting',
        expire_date: 'Test',
        status: 'NO',
        body: 'Hello everyone'
      )
    end
    it 'HAPPY: should find existing messages' do
      get "/api/v1/messages/#{@new_message.id}"
      _(last_response.status).must_equal 200
      results = JSON.parse(last_response.body)
      _(results['data']['id']).must_equal @new_message.id
    end

    it 'SAD: should not find non-existant message' do
      get "/api/v1/messages/#{random_str(10)}"
      _(last_response.status).must_equal 404
    end
  end
end
