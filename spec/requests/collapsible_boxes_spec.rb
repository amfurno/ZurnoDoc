require 'rails_helper'

RSpec.describe 'Collapsible boxes on patient show page', type: :request do
  let(:user) { create(:user) }
  let(:patient) { create(:patient, user: user) }

  def sign_in
    post session_path, params: { email_address: user.email_address, password: 'password123' }
  end

  before do
    sign_in
    get patient_path(patient)
  end

  it 'mounts the collapsible Stimulus controller on each section box' do
    expect(response.body).to include('data-controller="collapsible"')
  end

  it 'sets the correct key values for each section' do
    expect(response.body).to include('data-collapsible-key-value="doctors"')
    expect(response.body).to include('data-collapsible-key-value="medications"')
    expect(response.body).to include('data-collapsible-key-value="visits"')
  end

  it 'wires the header row click to the toggle action' do
    expect(response.body).to include('data-action="click->collapsible#toggle"')
  end

  it 'renders a collapsible content target for each section' do
    expect(response.body.scan('data-collapsible-target="content"').length).to eq(3)
  end

  it 'renders an icon target for each section' do
    expect(response.body.scan('data-collapsible-target="icon"').length).to eq(3)
  end

  it 'wires the action buttons to stop propagation' do
    expect(response.body).to include('collapsible#stopPropagation')
  end
end
