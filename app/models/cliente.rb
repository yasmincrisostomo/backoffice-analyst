class Cliente < ApplicationRecord
  self.primary_key = 'user_id'
  has_many :statuses, foreign_key: 'user_id'
end
