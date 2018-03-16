require 'twitter'

module Oauth
  class Twitter
    attr_reader :access_token, :formatted_account_info, :twitter_account

    def initialize(params)
      @consumer = OAuth::Consumer.new(ENV['TWITTER_KEY'], ENV['TWITTER_SECRET'], { :site => "https://api.twitter.com", :scheme => :header })
      @params = params
      get_account
      formatted_user_data 
    end

    def get_account
      token_hash = { :oauth_token => @params[:twitter_token], :oauth_token_secret => @params[:twitter_secret] }
      @access_token = OAuth::AccessToken.from_hash(@consumer, token_hash )
      response = @access_token.request(:get, "https://api.twitter.com/1.1/account/verify_credentials.json?include_email=true")
      @data = JSON.parse(response.body)
    end

    def authorized?
      @access_token.present? && ( !@data.keys.include? "errors" )
    end

    def formatted_user_data
      twitter_profile = @data
      @formatted_account_info = {
        provider:        'twitter', 
        uid:             twitter_profile["id"],
        name:            twitter_profile["name"],
        description:     twitter_profile["description"],
        token:           @params[:twitter_token],
        secret:          @params[:twitter_secret],
        image_url:       twitter_profile["profile_image_url_https"],
        twitter_profile: "http://www.twitter.com/#{twitter_profile['screen_name']}",
        email: twitter_profile["email"],
        username: twitter_profile['screen_name']
      }
    end
  end
end