# frozen_string_literal: true
module Api
  module V1
    class Users::RegistrationsController < Devise::RegistrationsController
      skip_before_action :doorkeeper_authorize!, raise: false
      
      # before_action :configure_sign_up_params, only: [:create]
      # before_action :configure_account_update_params, only: [:update]

      # GET /resource/sign_up
      # def new
      #   super
      # end

      # POST /resource
      def create
        build_resource(sign_up_params)
        if resource.save
          if resource.persisted?
            if resource.active_for_authentication?
              sign_up(resource_name, resource)
            else
              expire_data_after_sign_in!
            end
            render_success_response( { user: single_record_serializer.new(resource, serializer: UserSerializer),
          },"Verification email has been sent to your email address")
          else
            render_unprocessable_entity_response(resource)
          end
        else
          render_unprocessable_entity_response(resource)
        end
      end

      # GET /resource/edit
      # def edit
      #   super
      # end

      # PUT /resource
      def update
        resource_updated = update_resource(resource, account_update_params)
        if resource_updated
          render_success_response( { user: single_record_serializer.new(resource, serializer: UserSerializer),
          },"Profile Updated successfully",200)
        else
          clean_up_passwords resource
          set_minimum_password_length
          render_unprocessable_entity_response(resource)
        end
      end

      # DELETE /resource
      # def destroy
      #   super
      # end

      # GET /resource/cancel
      # Forces the session data which is usually expired after sign
      # in to be expired now. This is useful if the user wants to
      # cancel oauth signing in/up in the middle of the process,
      # removing all OAuth session data.
      # def cancel
      #   super
      # end

      # protected

      # If you have extra params to permit, append them to the sanitizer.
      # def configure_sign_up_params
      #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
      # end

      # If you have extra params to permit, append them to the sanitizer.
      # def configure_account_update_params
      #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
      # end

      # The path used after sign up.
      # def after_sign_up_path_for(resource)
      #   super(resource)
      # end

      # The path used after sign up for inactive accounts.
      # def after_inactive_sign_up_path_for(resource)
      #   super(resource)
      # end
      def authenticate_scope!
        self.resource = resource_class.find(params[:id])
      end

      def update_resource(resource, params)
        resource.update_without_password(params)
      end
    end
  end
end
