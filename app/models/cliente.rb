class Cliente < ApplicationRecord
  has_many :status, foreign_key: 'user_id'
end
