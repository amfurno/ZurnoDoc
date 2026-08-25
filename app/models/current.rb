class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :patient
  delegate :user, to: :session, allow_nil: true
end
