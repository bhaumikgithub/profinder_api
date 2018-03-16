class AliasProfile < ApplicationRecord
	belongs_to :user

	has_attached_file :profile_picture, styles: { medium: "300x300>", thumb: "100x100>" }
	# Validate content type
	validates_attachment_content_type :profile_picture, content_type:  /\Aimage\/.*\z/
	# Validate filename
	validates_attachment_file_name :profile_picture, matches: [/png\Z/, /jpe?g\Z/]
end
