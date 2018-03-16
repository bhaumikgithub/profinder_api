# frozen_string_literal: true
module Api
  module V1
    class Users::ConfirmationsController < Devise::ConfirmationsController
      skip_before_action :doorkeeper_authorize!, raise: false
      
      # GET /resource/confirmation/new
      # def new
      #   super
      # end

      # POST /resource/confirmation
      # def create
      #   super
      # end

      # GET /resource/confirmation?confirmation_token=abcdef
      def show
        self.resource = resource_class.confirm_by_token(params[:confirmation_token])
        yield resource if block_given?

        if resource.errors.empty?
           render_success_response({ :users => single_record_serializer.new(resource, serializer: UserSerializer) }, "Your Account Verified Successfully.")
        else
          render_unprocessable_entity_response(resource)
        end
      end

      # protected

      # The path used after resending confirmation instructions.
      # def after_resending_confirmation_instructions_path_for(resource_name)
      #   super(resource_name)
      # end

      # The path used after confirmation.
      # def after_confirmation_path_for(resource_name, resource)
      #   super(resource_name, resource)
      # end
    end
  end
end
