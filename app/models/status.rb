class Status < ApplicationRecord
  belongs_to :cliente, foreign_key: 'user_id'
  enum status: [:pending_kyc, :pending_purchase, :manual_check, :approved, :blocked, :inactive]
end