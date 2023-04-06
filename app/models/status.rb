class Status < ApplicationRecord
  enum status: {
    pending_purchase: 'pending_purchase',
    pending_kyc: 'pending_kyc',
    manual_check: 'manual_check',
    approved: 'approved',
    blocked: 'blocked',
    inactive: 'inactive'
  }
  belongs_to :cliente, primary_key: 'user_id', foreign_key: 'user_id'
end
