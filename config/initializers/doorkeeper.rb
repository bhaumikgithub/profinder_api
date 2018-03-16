Doorkeeper.configure do
  # Change the ORM that doorkeeper will use (needs plugins)
  orm :active_record

  # This block will be called to check whether the resource owner is authenticated or not.
  resource_owner_authenticator do
    fail "Please configure doorkeeper resource_owner_authenticator block located in #{__FILE__}"
    # Put your resource owner authentication logic here.
    # Example implementation:
    #   User.find_by_id(session[:user_id]) || redirect_to(new_user_session_url)
  end
  resource_owner_from_credentials do |routes|
    if params[:login_type] == "1"
      @oauth = "Oauth::#{params['provider'].camelize}".constantize.new(params)  
       if @oauth.authorized?
        user = User.from_auth @oauth.formatted_user_data
        if user
          user
        else
          raise Doorkeeper::Errors::DoorkeeperError.new( "You registered with us using #{params[:provider]} " )
        end
      else
        raise Doorkeeper::Errors::DoorkeeperError.new( "There was an error with #{params[:provider]}. please try again." )
      end
    elsif params[:login_type] == "2" 
      user = User.instagram_login params

      if user && !user.confirmed?
        raise Doorkeeper::Errors::DoorkeeperError.new(200) , "test"
      elsif user && user.confirmed?
        user
      else
        raise Doorkeeper::Errors::DoorkeeperError.new('Invalid User ID and provider')
      end
    else
      user = User.where('username=? OR email=?', params[:username], params[:email]).first
      if user.present? && user.valid_password?(params[:password])
        raise Doorkeeper::Errors::DoorkeeperError.new("Please varify your account") unless user.confirmed?
        user
      else
        raise Doorkeeper::Errors::DoorkeeperError.new('Invalid email and password.')
      end
    end
  end

  # If you want to restrict access to the web interface for adding oauth authorized applications, you need to declare the block below.
  # admin_authenticator do
  #   # Put your admin authentication logic here.
  #   # Example implementation:
  #   Admin.find_by_id(session[:admin_id]) || redirect_to(new_admin_session_url)
  # end

  # Authorization Code expiration time (default 10 minutes).
  # authorization_code_expires_in 10.minutes

  # Access token expiration time (default 2 hours).
  # If you want to disable expiration, set this to nil.
  # access_token_expires_in 2.hours

  # Assign a custom TTL for implicit grants.
  # custom_access_token_expires_in do |oauth_client|
  #   oauth_client.application.additional_settings.implicit_oauth_expiration
  # end

  # Use a custom class for generating the access token.
  # https://github.com/doorkeeper-gem/doorkeeper#custom-access-token-generator
  access_token_generator '::Doorkeeper::JWT'

  # The controller Doorkeeper::ApplicationController inherits from.
  # Defaults to ActionController::Base.
  # https://github.com/doorkeeper-gem/doorkeeper#custom-base-controller
  # base_controller 'ApplicationController'

  # Reuse access token for the same resource owner within an application (disabled by default)
  # Rationale: https://github.com/doorkeeper-gem/doorkeeper/issues/383
  # reuse_access_token

  # Issue access tokens with refresh token (disabled by default)
  # use_refresh_token

  # Provide support for an owner to be assigned to each registered application (disabled by default)
  # Optional parameter confirmation: true (default false) if you want to enforce ownership of
  # a registered application
  # Note: you must also run the rails g doorkeeper:application_owner generator to provide the necessary support
  # enable_application_owner confirmation: false

  # Define access token scopes for your provider
  # For more information go to
  # https://github.com/doorkeeper-gem/doorkeeper/wiki/Using-Scopes
  # default_scopes  :public
  # optional_scopes :write, :update

  # Change the way client credentials are retrieved from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:client_id` and `:client_secret` params from the `params` object.
  # Check out the wiki for more information on customization
  # client_credentials :from_basic, :from_params

  # Change the way access token is authenticated from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:access_token` or `:bearer_token` params from the `params` object.
  # Check out the wiki for more information on customization
  # access_token_methods :from_bearer_authorization, :from_access_token_param, :from_bearer_param

  # Change the native redirect uri for client apps
  # When clients register with the following redirect uri, they won't be redirected to any server and the authorization code will be displayed within the provider
  # The value can be any string. Use nil to disable this feature. When disabled, clients must provide a valid URL
  # (Similar behaviour: https://developers.google.com/accounts/docs/OAuth2InstalledApp#choosingredirecturi)
  #
  # native_redirect_uri 'urn:ietf:wg:oauth:2.0:oob'

  # Forces the usage of the HTTPS protocol in non-native redirect uris (enabled
  # by default in non-development environments). OAuth2 delegates security in
  # communication to the HTTPS protocol so it is wise to keep this enabled.
  #
  # force_ssl_in_redirect_uri !Rails.env.development?

  # Specify what grant flows are enabled in array of Strings. The valid
  # strings and the flows they enable are:
  #
  # "authorization_code" => Authorization Code Grant Flow
  # "implicit"           => Implicit Grant Flow
  # "password"           => Resource Owner Password Credentials Grant Flow
  # "client_credentials" => Client Credentials Grant Flow
  #
  # If not specified, Doorkeeper enables authorization_code and
  # client_credentials.
  #
  # implicit and password grant flows have risks that you should understand
  # before enabling:
  #   http://tools.ietf.org/html/rfc6819#section-4.4.2
  #   http://tools.ietf.org/html/rfc6819#section-4.4.3
  #
  grant_flows %w(password)
  # grant_flows %w(authorization_code client_credentials)

  # Under some circumstances you might want to have applications auto-approved,
  # so that the user skips the authorization step.
  # For example if dealing with a trusted application.
  # skip_authorization do |resource_owner, client|
  #   client.superapp? or resource_owner.admin?
  # end

  skip_authorization do
    true
  end

  # WWW-Authenticate Realm (default "Doorkeeper").
  # realm "Doorkeeper"
end
Doorkeeper::JWT.configure do
  # Set the payload for the JWT token. This should contain unique information
  # about the user.
  # Defaults to a randomly generated token in a hash
  # { token: "RANDOM-TOKEN" }
  token_payload do |opts|
    user = User.find(opts[:resource_owner_id])

    {
      user: {
        id: user.id,
        email: user.email,
        issue_time: Time.current.to_i
      }
    }
  end

  # Use the application secret specified in the Access Grant token
  # Defaults to false
  # If you specify `use_application_secret true`, both secret_key and secret_key_path will be ignored
  secret_key Rails.application.secrets.secret_key_base
  encryption_method :hs512

  # For custom token response format
  Doorkeeper::OAuth::TokenResponse.send :prepend, CustomTokenResponse
end
module Doorkeeper
  module OAuth
    class ErrorResponse < BaseResponse
      include OAuth::Helpers

      def self.from_request(request, attributes = {})
        binding.pry
        state = request.state if request.respond_to?(:state)
        new(attributes.merge(name: request.error, state: state))
      end

      delegate :name, :description, :state , :status, to: :@error

      def initialize(attributes = {})
        binding.pry

        @error = OAuth::Error.new(*attributes.values_at(:name, :state))
        @redirect_uri = attributes[:redirect_uri]
        @response_on_fragment = attributes[:response_on_fragment]
      end

      def body
        {
          error: name,
          error_description: description,
          state: state
        }.reject { |_, v| v.blank? }
      end

      def status
        :ok
      end

      def redirectable?
        name != :invalid_redirect_uri && name != :invalid_client &&
          !URIChecker.native_uri?(@redirect_uri)
      end

      def redirect_uri
        if @response_on_fragment
          Authorization::URIBuilder.uri_with_fragment @redirect_uri, body
        else
          Authorization::URIBuilder.uri_with_query @redirect_uri, body
        end
      end

      def headers
        { 'Cache-Control' => 'no-store',
          'Pragma' => 'no-cache',
          'Content-Type' => 'application/json; charset=utf-8',
          'WWW-Authenticate' => authenticate_info }
      end

      protected

      delegate :realm, to: :configuration

      def configuration
        Doorkeeper.configuration
      end

      private

      def authenticate_info
        %(Bearer realm="#{realm}", error="#{name}", error_description="#{description}")
      end
    end
  end
end

module Doorkeeper
  module Errors
    class DoorkeeperError < StandardError

      attr_reader :code

      def initialize(code)
        super
        @code = code
      end
      def type
        
        
      end
      
    end
  end
end