class AddUsernameToAliasProfiles < ActiveRecord::Migration[5.1]
  def change
    add_column :alias_profiles, :username, :string
  end
end
