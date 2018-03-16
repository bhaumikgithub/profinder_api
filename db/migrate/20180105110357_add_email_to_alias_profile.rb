class AddEmailToAliasProfile < ActiveRecord::Migration[5.1]
  def change
    add_column :alias_profiles, :email, :string
  end
end
