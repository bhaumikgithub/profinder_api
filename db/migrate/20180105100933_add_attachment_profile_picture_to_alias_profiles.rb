class AddAttachmentProfilePictureToAliasProfiles < ActiveRecord::Migration[5.1]
  def self.up
    change_table :alias_profiles do |t|
      t.attachment :profile_picture
    end
  end

  def self.down
    remove_attachment :alias_profiles, :profile_picture
  end
end
