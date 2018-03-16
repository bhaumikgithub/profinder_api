module Oauth
  class Base
    attr_reader :provider, :data, :access_token, :uid

    def initialize params
      @provider = self.class.name.split('::').last.downcase
      @client = HTTPClient.new
      @access_token = params[:access_token].presence
      get_data if @access_token.present?
    end

    def authorized?
      @access_token.present? && ( !@data.keys.include? "error" )
    end

  end

end