require "rails_helper"

RSpec.describe HealthMetricPolicy, type: :policy do
  subject(:policy) { described_class.new(user, health_metric) }

  let(:owner)      { create(:user) }
  let(:other_user) { create(:user) }
  let(:patient)    { create(:patient, user: owner) }
  let(:health_metric) { create(:health_metric, patient: patient) }

  context "when the user owns the parent patient" do
    let(:user) { owner }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
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
  end

  describe "Scope" do
    subject(:scope) { described_class::Scope.new(user, HealthMetric.all).resolve }

    let(:user) { owner }

    it "includes metrics belonging to the user's patients" do
      owned = create(:health_metric, patient: patient)
      create(:health_metric, patient: create(:patient, user: other_user))
      expect(scope).to include(owned)
    end

    it "excludes metrics belonging to other users' patients" do
      create(:health_metric, patient: patient)
      other = create(:health_metric, patient: create(:patient, user: other_user))
      expect(scope).not_to include(other)
    end
  end
end
