# frozen_string_literal: true

require "rails_helper"

RSpec.describe PatientPolicy, type: :policy do
  subject(:policy) { described_class.new(user, patient) }

  let(:owner) { create(:user) }
  let(:user) { owner }
  let(:other_user) { create(:user) }
  let(:patient) { create(:patient, user: owner) }

  context "when the user owns the patient" do
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context "when the user does not own the patient" do
    let(:user) { other_user }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context "when the user is authenticated (any user)" do
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
  end

  describe "Scope" do
    subject(:scope) { described_class::Scope.new(user, Patient.all).resolve }

    it "includes the user's own patients" do
      owned = create(:patient, user: user)
      create(:patient, user: other_user)
      expect(scope).to include(owned)
    end

    it "excludes other users' patients" do
      create(:patient, user: user)
      other = create(:patient, user: other_user)
      expect(scope).not_to include(other)
    end
  end
end
