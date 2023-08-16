class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtBlacklist

  has_one :profile
  has_many :posts
  has_many :comments
  has_many :likes

  has_many :votes
  
  # has_many :followings, class_name: 'Follow', foreign_key: :follower_id
  # has_many :followers, class_name: 'Follow', foreign_key: :followed_id

  # Followers - people who follow this user
  has_many :follower_relationships, foreign_key: :followed_id, class_name: 'Follower', dependent: :destroy
  has_many :followers, through: :follower_relationships, source: :follower

  # Following - people this user is following
  has_many :followed_relationships, foreign_key: :follower_id, class_name: 'Follower', dependent: :destroy
  has_many :followings, through: :followed_relationships, source: :followed 

  has_many :my_subscriptions
  has_one :remaining_attempt

  # has_many :revisions
  has_many :saved_posts
  has_many :saved_for_later, through: :saved_posts, source: :post

  has_many :user_subscriptions
  has_many :subscriptions, through: :user_subscriptions

  after_create :add_profile

  def add_profile
    build_profile.save
  end
end

# Dummy test case

# Kartik Pavan

# Pavan follow Kartik => Follow table => follower_id: :paven_id,  followings_id: :kartik_id

# Pavan => followers => 0
# Pavan => followings => 1

# Kartik follow Paven => Follow table => follower_id: :kartik_id,  followings_id: :paven_id

# Pavan => followers => 1
# Pavan => followings => 1
