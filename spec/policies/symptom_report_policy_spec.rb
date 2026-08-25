require 'rails_helper'

RSpec.describe SymptomReportPolicy, type: :policy do
  subject(:policy) { described_class.new(user, record) }

  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }
  let(:patient) { create(:patient, user: owner) }
  let(:record) { Struct.new(:patient).new(patient) }

  context 'when the user owns the parent patient' do
    let(:user) { owner }

    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
  end

  context 'when the user does not own the parent patient' do
    let(:user) { other_user }

    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
  end
end
