require_relative './spec_helper'

describe 'Testing unit level properties of accounts' do
  before do
    Public_key.dataset.destroy
    Message.dataset.destroy
    Account.dataset.destroy

    @original_password = 'security'
    @account = CreateAccount.call(
      username: 'odilon.koutou',
      email: 'odilon.koutou@nthu.edu.tw',
      password: @original_password)
  end

  it 'HAPPY: should hash the password' do
    _(@account.password_hash).wont_equal @original_password
  end

  it 'HAPPY: should re-salt the password' do
    hashed = @account.password_hash
    @account.password = @original_password
    @account.save
    _(@account.password_hash).wont_equal hashed
  end
end

describe 'Testing Account resource routes' do
  before do
    Public_key.dataset.destroy
    Message.dataset.destroy
    Account.dataset.destroy
  end

  describe 'Creating new account' do
    before do
      registration_data = {
        username: 'test.name',
        password: 'mypass',
        email: 'test@email.com' }
      @req_body = registration_data.to_json
    end

    it 'HAPPY: should create a new unique account' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post '/api/v1/accounts/', @req_body, req_header
      _(last_response.status).must_equal 201
      _(last_response.location).must_match(%r{http://})
    end

    it 'SAD: should not create accounts with duplicate usernames' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post '/api/v1/accounts/', @req_body, req_header
      post '/api/v1/accounts/', @req_body, req_header
      _(last_response.status).must_equal 400
      _(last_response.location).must_be_nil
    end
  end


  describe 'Finding an existing account' do
    before do
      @new_account = CreateAccount.call(
        username: 'test.name',
        email: 'test@email.com', password: 'mypassword')
    end

    it 'HAPPY: should find an existing account' do
      get "/api/v1/accounts/#{@new_account.id}"
      _(last_response.status).must_equal 200

      results = JSON.parse(last_response.body)
      _(results['data']['id']).must_equal @new_account.id
    end

    it 'SAD: should not return wrong account' do
      get "/api/v1/accounts/#{random_str(10)}"
      _(last_response.status).must_equal 401
    end
  end

  describe 'Authenticating an account' do
    before do
      @new_account = CreateAccount.call(
        username: 'test.name',
        email: 'test@email.com', password: 'mypass'
      )
    end

    it 'HAPPY: should authenticate an existing account' do
      credentials = {
        username: 'test.name',
        password: 'mypass'
      }
      @req_body = credentials.to_json
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post '/api/v1/accounts/authenticate', @req_body, req_header
      _(last_response.status).must_equal 200

      results = JSON.parse(last_response.body)
      _(results['account']['id']).must_equal @new_account.id
    end

    it 'SAD: should not authenticate, wrong password' do
      credentials = {
        username: 'test.name',
        password: 'wrongpass'
      }
      @req_body = credentials.to_json
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post '/api/v1/accounts/authenticate', @req_body, req_header
      _(last_response.status).must_equal 403
    end
  end
end
