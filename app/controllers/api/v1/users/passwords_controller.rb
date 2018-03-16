# frozen_string_literal: true
module Api
  module V1
    class Users::PasswordsController < Devise::PasswordsController
      skip_before_action :doorkeeper_authorize!, raise: false

      # GET /resource/password/new
      # def new
      #   super
      # end

      # POST /resource/password
      def create
        self.resource = User.find_by_email(resource_params[:email])
        if resource.present?
          token = resource.send_reset_password_instructions
          yield resource if block_given?
          if successfully_sent?(resource)
             render_success_response(
              { token: token },
              "Reset token sent to email: #{resource_params[:email]}"
              )
          else
            render_unprocessable_entity_response(resource)
          end
        else
          json_response({
          success: false,
          message: "You are not registered with this email address"
        }, 404)
        end
      end

      # GET /resource/password/edit?reset_password_token=abcdef
      # def edit
      #   super
      # end

      # PUT /resource/password
      def update
        self.resource = resource_class.reset_password_by_token(resource_params)
        yield resource if block_given?
        if resource.errors.empty?
          resource.unlock_access! if unlockable?(resource)
          render_success_response(
            {
              user: ActiveModelSerializers::SerializableResource.new(resource, serializer: UserSerializer)
            }, "Your password created successfully"
          )
        else
          set_minimum_password_length
          render_unprocessable_entity_response(resource)
        end
      end

      # protected

      # def after_resetting_password_path_for(resource)
      #   super(resource)
      # end

      # The path used after sending reset password instructions
      # def after_sending_reset_password_instructions_path_for(resource_name)
      #   super(resource_name)
      # end
    end
  end
end
