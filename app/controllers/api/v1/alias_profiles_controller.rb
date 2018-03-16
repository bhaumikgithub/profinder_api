module Api
  module V1
    class AliasProfilesController <  Api::V1::ApiController
    	
      #POST /api/v1/users/:user_id/alias_profiles
      def create
        unless current_resource_owner.alias_profile.present?
          current_resource_owner.create_alias_profile(user_alias_profile_params)
          return_response
        end
      end

      #PUT /api/v1/users/:user_id/alias_profiles/:id
      def update
        current_resource_owner.alias_profile.update_attributes(user_alias_profile_params)
        return_response
      end

      #GET /api/v1/users/:user_id/alias_profiles/:id
      def show
        return_response
      end

      #response
      def return_response
        json_response({
          success: true,
          data: {
            user: single_record_serializer.new(current_resource_owner.alias_profile, serializer: UserSerializer),
          }
        }, 200)
      end

      private

      def user_alias_profile_params
        params.require(:user).permit(:first_name,:last_name,:phone_number,:profile_picture,:email,:username)
      end

    end
  end
end
