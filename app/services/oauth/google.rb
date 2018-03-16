module Oauth
  class Google < Oauth::Base
    DATA_URL = 'https://www.googleapis.com/plus/v1/people/me'

    def get_data
      response = @client.get(DATA_URL, access_token: @access_token)
      binding.pry
      @data = JSON.parse(response.body).with_indifferent_access
      @uid = @data[:id] ||= @data[:sub]
      @data
    end

    def formatted_user_data
      {
        provider:       'google',
        token:          @access_token,
        uid:            @data['id'],
        first_name:     @data['given_name'],
        last_name:      @data['family_name'],
        email:          @data['email'],
        image_url:      @data['picture'].gsub("?sz=50", ""),
        google_profile: @data['profile']
      }
    end    

  end
end