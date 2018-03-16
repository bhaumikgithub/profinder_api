class CreateSocialAuths < ActiveRecord::Migration[5.1]
  def change
    create_table :social_auths do |t|
      t.string :provider
      t.string :uid
      t.string :secret
      t.string :token
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
