class Cliente < ApplicationRecord
  has_many :statuses, foreign_key: 'user_id'
end
