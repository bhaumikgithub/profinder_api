module CustomTokenResponse
  def body
    user_details = User.find(@token.resource_owner_id)
    social_auths = user_details.social_auths.find_by(provider:"instagram")
    { 
      success: true,
      message: "",
      data: {
        token: super,
        user: ActiveModelSerializers::SerializableResource.new(user_details, serializer: Api::V1::UserSerializer),
        social_auth: social_auths.as_json
      },
      meta: [],
      errors: []
    }
  end
end