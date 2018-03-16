module Oauth
  class Instagram < Oauth::Base
  	DATA_URL= "https://api.instagram.com/v1/users/self/"
  	def get_data
      response = @client.get(DATA_URL, access_token: @access_token)
      @data = JSON.parse(response.body).with_indifferent_access
      @data
    end

    def formatted_user_data
      user_profile = @data["data"]
      formatted_user_data = user_profile
      {
        name:       	    user_profile['full_name'],
        image_url:        user_profile['profile_picture'],
        provider:        'instagram',
        token:            @access_token,
        email:            user_profile['email'],
        uid:              user_profile['id'],
        username:         user_profile['username']
      }
    end

    def authorized?
      @access_token.present? && ( !@data.dig(:meta,:error_type).present? )
    end
  end
end