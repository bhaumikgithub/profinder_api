Rails.application.routes.draw do

	scope 'api/v1' do
    use_doorkeeper
  end

	namespace :api, as: nil, defaults: { format: 'json' } do
    namespace :v1, as: nil do

			devise_for :users,defaults: { format: 'json' }, controllers: {
		  	registrations: "api/v1/users/registrations",
		    passwords: "api/v1/users/passwords",
        confirmations:  "api/v1/users/confirmations"
		  }

		  resources :users, only: [:show] do
		  	resources :alias_profiles, only: [:update,:show,:create]
        collection do
          post "/token_varification" => "users#token_verification"
        end
		  end
		end
	end
end
