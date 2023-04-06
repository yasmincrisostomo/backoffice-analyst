class Cliente < ApplicationRecord
  has_many :statuses, primary_key: 'user_id', foreign_key: 'user_id'
end
