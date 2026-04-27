class Session < ApplicationRecord
  SESSION_LENGTH = 10.minutes
  ABSOLUTE_TTL = 14.days

  belongs_to :user

  scope :active, -> { where("expires_at > ?", Time.current) }

  before_validation :set_expiry_defaults, on: :create

  validates :expires_at, :absolute_expires_at, presence: true

  def expired?
    expires_at <= Time.current
  end

  def slide!
    return false if Time.current >= absolute_expires_at

    next_expiry = [ Time.current + SESSION_LENGTH, absolute_expires_at ].min
    update!(expires_at: next_expiry)
  end

  private

    def set_expiry_defaults
      now = Time.current
      self.absolute_expires_at ||= now + ABSOLUTE_TTL
      self.expires_at ||= [ now + SESSION_LENGTH, absolute_expires_at ].min
    end
end
