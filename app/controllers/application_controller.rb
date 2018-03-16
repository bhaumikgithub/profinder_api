class ApplicationController < ActionController::API
  include ApplicationMethods
	
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    allow_keys = [:first_name, :last_name, :email,:password, :profile_picture, :phone_number,:username,:interest,:area]
    devise_parameter_sanitizer.permit(:sign_up, keys: allow_keys)
    devise_parameter_sanitizer.permit(:account_update,keys: allow_keys)
  end
 
end
