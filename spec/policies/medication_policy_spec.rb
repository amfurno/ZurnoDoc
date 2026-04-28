# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicationPolicy, type: :policy do
  subject(:policy) { described_class.new(user, medication) }

  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }
  let(:patient) { create(:patient, user: owner) }
  let(:medication) { create(:medication, patient: patient) }

  context "when the user owns the parent patient" do
    let(:user) { owner }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:stop) }
  end

  context "when the user does not own the parent patient" do
    let(:user) { other_user }

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:stop) }
  end

  describe "Scope" do
    subject(:scope) { described_class::Scope.new(user, Medication.all).resolve }

    let(:user) { owner }

    it "includes medications belonging to the user's patients" do
      owned = create(:medication, patient: patient)
      create(:medication, patient: create(:patient, user: other_user))
      expect(scope).to include(owned)
    end

    it "excludes medications belonging to other users' patients" do
      create(:medication, patient: patient)
      other = create(:medication, patient: create(:patient, user: other_user))
      expect(scope).not_to include(other)
    end
  end
end
