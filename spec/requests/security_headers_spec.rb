require 'rails_helper'

RSpec.describe 'Security headers', type: :request do
  subject(:response_headers) do
    get patients_path
    response.headers
  end

  let(:user) { create(:user) }

  def sign_in
    post session_path, params: { email_address: user.email_address, password: 'password123' }
  end

  before { sign_in }

  describe 'Content-Security-Policy' do
    it 'is present' do
      expect(response_headers['Content-Security-Policy']).to be_present
    end

    it 'disallows framing via frame-ancestors' do
      expect(response_headers['Content-Security-Policy']).to include("frame-ancestors 'none'")
    end

    it 'restricts object-src to none' do
      expect(response_headers['Content-Security-Policy']).to include("object-src 'none'")
    end

    it 'restricts form-action to self' do
      expect(response_headers['Content-Security-Policy']).to include("form-action 'self'")
    end
  end

  describe 'X-Frame-Options' do
    it 'is set to DENY' do
      expect(response_headers['X-Frame-Options']).to eq('DENY')
    end
  end

  describe 'X-Content-Type-Options' do
    it 'is set to nosniff' do
      expect(response_headers['X-Content-Type-Options']).to eq('nosniff')
    end
  end

  describe 'Referrer-Policy' do
    it 'is set to strict-origin-when-cross-origin' do
      expect(response_headers['Referrer-Policy']).to eq('strict-origin-when-cross-origin')
    end
  end

  describe 'Permissions-Policy' do
    it 'is present' do
      expect(response_headers['Permissions-Policy']).to be_present
    end

    it 'restricts camera access' do
      policy = response_headers['Permissions-Policy']
      expect(policy).to include('camera=()')
    end

    it 'restricts microphone access' do
      policy = response_headers['Permissions-Policy']
      expect(policy).to include('microphone=()')
    end

    it 'restricts geolocation access' do
      policy = response_headers['Permissions-Policy']
      expect(policy).to include('geolocation=()')
    end

    it 'restricts payment access' do
      policy = response_headers['Permissions-Policy']
      expect(policy).to include('payment=()')
    end
  end

  describe 'Cross-Origin-Opener-Policy' do
    it 'is set to same-origin' do
      expect(response_headers['Cross-Origin-Opener-Policy']).to eq('same-origin')
    end
  end

  describe 'Cross-Origin-Resource-Policy' do
    it 'is set to same-origin' do
      expect(response_headers['Cross-Origin-Resource-Policy']).to eq('same-origin')
    end
  end
end
