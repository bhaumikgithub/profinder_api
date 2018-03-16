module Api
  module V1
  	class Api::V1::UserSerializer < ActiveModel::Serializer
	    
	    attributes :id,:email,:last_name,:first_name,:phone_number,:profile_picture,:username,:interest,:area

	    def profile_picture
  			CommonSerializer.full_attactment_url(object.profile_picture.url(:thumb)) if object.profile_picture.present?
  		end

    end
	end
end
