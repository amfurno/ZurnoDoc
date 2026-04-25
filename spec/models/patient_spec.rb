require 'rails_helper'

RSpec.describe Patient, type: :model do
  subject(:patient) { Patient.new(name: 'John Smith', user: user) }

  let(:user) { User.create!(email_address: 'user@example.com', password: 'password123') }


  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(patient).to be_valid
    end

    it 'is invalid without a name' do
      patient.name = nil
      expect(patient).not_to be_valid
    end

    it 'is invalid without a user' do
      patient.user = nil
      expect(patient).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a user' do
      expect(Patient.reflect_on_association(:user).macro).to eq(:belongs_to)
    end

    it 'has many doctors' do
      expect(Patient.reflect_on_association(:doctors).macro).to eq(:has_many)
    end

    it 'destroys associated doctors when destroyed' do
      patient.save!
      patient.doctors.create!(name: 'Dr. Jones')
      expect { patient.destroy }.to change(Doctor, :count).by(-1)
    end
  end
end
