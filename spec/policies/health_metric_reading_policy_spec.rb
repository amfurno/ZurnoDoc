require 'rails_helper'

RSpec.describe HealthMetricReadingPolicy, type: :policy do
  subject(:policy) { described_class.new(user, reading) }

  let(:owner)      { create(:user) }
  let(:other_user) { create(:user) }
  let(:patient)    { create(:patient, user: owner) }
  let(:metric)     { create(:health_metric, patient: patient) }
  let(:reading)    { create(:health_metric_reading, health_metric: metric) }

  context 'when the user owns the parent patient' do
    let(:user) { owner }

    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'when the user does not own the parent patient' do
    let(:user) { other_user }

    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe 'Scope' do
    subject(:scope) { described_class::Scope.new(user, HealthMetricReading.all).resolve }

    let(:user) { owner }

    it "includes readings belonging to the user's metrics" do
      owned = create(:health_metric_reading, health_metric: metric)
      other_metric = create(:health_metric, patient: create(:patient, user: other_user))
      create(:health_metric_reading, health_metric: other_metric)
      expect(scope).to include(owned)
    end

    it "excludes readings belonging to other users' metrics" do
      create(:health_metric_reading, health_metric: metric)
      other_metric = create(:health_metric, patient: create(:patient, user: other_user))
      other = create(:health_metric_reading, health_metric: other_metric)
      expect(scope).not_to include(other)
    end
  end
end
