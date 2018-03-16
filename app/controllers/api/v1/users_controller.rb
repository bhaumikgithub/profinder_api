module Api
  module V1
    class UsersController < Api::V1::ApiController
      include InheritAction

      skip_before_action :doorkeeper_authorize!, only: [:token_verification]
      before_action :unauthorized, only: :show

      #GET /api/v1/users/:id
      def show
        json_response({
          success: true,
          data: {
            user: single_record_serializer.new(@resource, serializer: UserSerializer),
          }
        }, 200)
      end

      #POST /api/v1/users/token_varification - reset password token varification
      def token_verification
        user = User.with_reset_password_token(params[:user][:reset_password_token])
        if user && user.email ==  params[:user][:email] && user.reset_password_period_valid?
          render_success_response({},"Token is valid")
        else
          json_response({
          success: false,
          message: "Invalid Token"
        }, 400)
        end
      end

      private

      # check user authentication
      def unauthorized
        json_response({
          success: false,
          message: "You are not authorized."
        }, 401) and return if @resource.id != current_resource_owner.id
      end

      def user_params
        params.require(:user).permit(:first_name,:last_name,:phone_number,:profile_picture,:email)
      end

    end
  end
end
