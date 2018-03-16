class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  
  devise :database_authenticatable, :registerable,:confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # validates :first_name, :last_name ,presence: true

  # validates :phone_number, :numericality => true,:length => { :minimum => 10, :maximum => 15 }

  has_attached_file :profile_picture, styles: { medium: "300x300>", thumb: "100x100>" }

  # Validate content type
  validates_attachment_content_type :profile_picture, content_type:  /\Aimage\/.*\z/

  # Validate filename
  validates_attachment_file_name :profile_picture, matches: [/png\Z/, /jpe?g\Z/]

  has_one :alias_profile, dependent: :destroy
  has_many :social_auths, dependent: :destroy
  
  def self.from_auth params
    params = params.with_indifferent_access
    socialAuth = SocialAuth.find_or_initialize_by(provider: params[:provider], uid: params[:uid])
    if socialAuth.persisted?
      user = socialAuth.user
    else
      if params[:email].present?
        user = User.find_or_initialize_by(email: params[:email])
      else
        user = User.new
      end
    end

    socialAuth.secret = params[:secret]
    socialAuth.token  = params[:token]
    fallback_name        = params[:name].split(" ") if params[:name]
    fallback_first_name  = fallback_name.try(:first)
    fallback_last_name   = fallback_name.try(:last)

    first_name    ||= (params[:first_name] || fallback_first_name)
    last_name     ||= (params[:last_name]  || fallback_last_name)
    
    user.first_name = "#{first_name}"
    user.last_name = "#{last_name}"
    user.username = params[:username]
    
    user.password = SecureRandom.urlsafe_base64.to_s if user.password.blank?
    if user.profile_picture.blank?
      user.profile_picture = params[:image_url]
    end

    if user.email.blank?
      user.save(validate: false)
    else
      user.save
    end
    socialAuth.user_id ||= user.id
    socialAuth.save
    user
  end

  def self.instagram_login params
    user = User.find_by(email: params[:email])
    user.destroy if user.present?
    auth_user = SocialAuth.find_by(uid:params[:uid] ,provider:params[:provider])&.user
    auth_user.update_attributes(email:params[:email],phone_number: params[:phone_number]) if auth_user.present?
    auth_user
    # if auth_user && auth_user.confirmed? 
    #   auth_user
    # elsif auth_user && !auth_user.confirmed?
    #   render_success_response( {},"A Verification email has been sent to your email address",200)
    # else
    # end
  end

end
