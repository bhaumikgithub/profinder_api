module Oauth
  class Google < Oauth::Base
    DATA_URL = 'https://www.googleapis.com/plus/v1/people/me'
    attr_reader :provider, :data, :access_token, :uid

    
    def initialize params
      @data = {}
      @data['id'] = params["google_id"]
      @data['given_name'] = params["given_name"]
      @data['family_name'] =params["family_name"]
      @data['email'] = params["email"]
      @data['profile']= params["profile"]
      @access_token = params[:access_token].presence
      @data
    end

    def get_data
      # response = @client.get(DATA_URL, access_token: @access_token)
      # @data = JSON.parse(response.body).with_indifferent_access
      # @uid = @data[:id] ||= @data[:sub]
      # @data
    end

    def formatted_user_data
      {
        provider:       'google',
        token:          @access_token,
        uid:            @data['id'],
        first_name:     @data['given_name'],
        last_name:      @data['family_name'],
        email:          @data['email'],
        google_profile: @data['profile']
      }
    end    

  end
end