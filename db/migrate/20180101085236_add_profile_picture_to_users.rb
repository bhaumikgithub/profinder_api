class AddProfilePictureToUsers < ActiveRecord::Migration[5.1]
  def up
    add_attachment :users, :profile_picture
  end
 
  def down
    remove_attachment :users, :profile_picture
  end
end
