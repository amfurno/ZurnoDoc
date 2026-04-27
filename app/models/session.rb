class Session < ApplicationRecord
  SESSION_LENGTH = 10.minutes
  ABSOLUTE_TTL = 14.days

  belongs_to :user

  scope :active, -> { where("expires_at > ?", Time.current) }

  before_validation :set_expiry_defaults, on: :create

  validates :expires_at, :absolute_expires_at, presence: true

  def expired?
    now = Time.current
    return expires_at <= now || absolute_expires_at <= now
  end

  def slide!(window = SESSION_LENGTH)
    if Time.current >= absolute_expires_at
      destroy!
      return false
    end

    next_expiry = [ Time.current + window, absolute_expires_at ].min
    update!(expires_at: next_expiry)
  end

  private

    def set_expiry_defaults
      now = Time.current
      self.absolute_expires_at ||= now + ABSOLUTE_TTL
      self.expires_at ||= [ now + SESSION_LENGTH, absolute_expires_at ].min
    end
end
