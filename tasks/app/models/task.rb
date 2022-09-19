class Task < ApplicationRecord
  belongs_to :account

  validates :title, :description, presence: true
end
