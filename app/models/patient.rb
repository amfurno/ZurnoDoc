class Patient < ApplicationRecord
  belongs_to :user
  has_many :doctors, dependent: :destroy
  has_many :medications, dependent: :destroy
  has_many :health_metrics, dependent: :destroy

  validates :name, presence: true
end
