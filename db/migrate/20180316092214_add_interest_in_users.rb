class AddInterestInUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :interest, :string
    add_column :users, :area, :string
  end
end
