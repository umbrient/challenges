class Comment < ApplicationRecord

    validates :user_id, presence: true  
    validates :post_id, presence: true
    validates :body, presence: true, length: { minimum: 5, maximum: 80 }

    belongs_to :user 
    belongs_to :post 

end
