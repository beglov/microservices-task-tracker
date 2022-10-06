class PaymentTransaction < ApplicationRecord
  belongs_to :account
  belongs_to :task, optional: true
end
