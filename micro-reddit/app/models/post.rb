class Post < ApplicationRecord

    validates :title, presence: true, length: { minimum: 10, maximum: 100 }
    validates :content, presence: true, uniqueness: true, length: { minimum: 10, maximum: 140 }

    belongs_to :user
    has_many :comments

end
