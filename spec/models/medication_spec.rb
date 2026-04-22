require 'rails_helper'

RSpec.describe Medication, type: :model do
  let(:user) { User.create!(email_address: 'user@example.com', password: 'password123') }
  let(:patient) { user.patients.create!(name: 'Jane Doe') }

  subject(:medication) { Medication.new(name: 'Metformin', patient: patient) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(medication).to be_valid
    end

    it 'is invalid without a name' do
      medication.name = nil
      expect(medication).not_to be_valid
    end

    it 'is invalid without a patient' do
      medication.patient = nil
      expect(medication).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a patient' do
      expect(Medication.reflect_on_association(:patient).macro).to eq(:belongs_to)
    end

    it 'belongs to an optional doctor' do
      expect(Medication.reflect_on_association(:doctor).macro).to eq(:belongs_to)
      expect(Medication.reflect_on_association(:doctor).options[:optional]).to be(true)
    end
  end
end
