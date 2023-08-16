class Post < ApplicationRecord
  belongs_to :user
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :saved_posts
  has_many :saved_by_users, through: :saved_posts, source: :user

  before_save :calculate_reading_time

  has_one_attached :avatar
  has_many :lists
  # has_many :revisions
  has_many :votes
  
  enum status: {
    draft: 0,
    unpublished: 1,
    published: 2
  }

  scope :published_posts, -> { where(status: :published) }
  scope :draft_posts, -> { where(status: :draft) }
  scope :unpublished_posts, -> { where(status: :unpublished) }

  private

  def calculate_reading_time
    words_per_minute = 50 # Adjust this value based on your estimation
    word_count = content.split.size
    minutes = (word_count / words_per_minute).ceil
    minutes = 1 if minutes.zero? # At least 1 minute
    self.reading_time = minutes
  end
end
