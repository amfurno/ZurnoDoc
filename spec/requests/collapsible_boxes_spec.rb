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

  it 'sets the doctors key scoped to the patient' do
    expect(response.body).to include("data-collapsible-key-value=\"patient-#{patient.id}-doctors\"")
  end

  it 'sets the medications key scoped to the patient' do
    expect(response.body).to include("data-collapsible-key-value=\"patient-#{patient.id}-medications\"")
  end

  it 'sets the visits key scoped to the patient' do
    expect(response.body).to include("data-collapsible-key-value=\"patient-#{patient.id}-visits\"")
  end

  it 'sets the health-metrics key scoped to the patient' do
    expect(response.body).to include("data-collapsible-key-value=\"patient-#{patient.id}-health-metrics\"")
  end

  it 'wires the header row click to the toggle action on all three sections' do
    expect(response.body.scan('click->collapsible#toggle').length).to eq(4)
  end

  it 'wires the header row enter key to the toggle action on all three sections' do
    expect(response.body.scan('keydown.enter->collapsible#toggle').length).to eq(4)
  end

  it 'wires the header row space key to the toggle action on all three sections' do
    expect(response.body.scan('keydown.space->collapsible#toggle').length).to eq(4)
  end

  it 'renders the header target on each section' do
    expect(response.body.scan('data-collapsible-target="header"').length).to eq(4)
  end

  it 'renders aria-expanded on each section header' do
    expect(response.body.scan('aria-expanded="true"').length).to eq(4)
  end

  it 'renders a collapsible content target for each section' do
    expect(response.body.scan('data-collapsible-target="content"').length).to eq(4)
  end

  it 'renders an icon target for each section' do
    expect(response.body.scan('data-collapsible-target="icon"').length).to eq(4)
  end

  it 'renders role=button on each section header' do
    expect(response.body.scan(/role="button"[^>]*data-collapsible-target="header"|data-collapsible-target="header"[^>]*role="button"/).length).to eq(4)
  end

  it 'renders tabindex=0 on each section header' do
    expect(response.body.scan('tabindex="0"').length).to eq(4)
  end

  it 'wires the action buttons to stop propagation' do
    expect(response.body).to include('collapsible#stopPropagation')
  end
end
