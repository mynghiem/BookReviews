class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  acts_as_voter

  has_many :books
  has_many :reviews, :dependent => :delete_all

  attr_reader :avatar_remote_url
  has_attached_file :avatar

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  has_attached_file :avatar, styles: { medium: "300x300#", thumb: "100x100#" }, default_url: ':placeholder'
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

  def admin?
  	admin
  end

  def regular?
    !admin
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name   # assuming the user model has a name
      user.avatar = URI.parse(auth.info.image) if auth.info.image? # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate emails,
      # uncomment the line below to skip the confirmation emails.
      # user.skip_confirmation!
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end



  def avatar_remote_url=(url_value)
    self.avatar = URI.parse(url_value)
    # Assuming url_value is http://example.com/photos/face.png
    # avatar_file_name == "face.png"
    # avatar_content_type == "image/png"
    @avatar_remote_url = url_value
  end

end
