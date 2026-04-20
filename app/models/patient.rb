class Patient < ApplicationRecord
  belongs_to :user
  has_many :doctors, dependent: :destroy

  validates :name, presence: true
end
