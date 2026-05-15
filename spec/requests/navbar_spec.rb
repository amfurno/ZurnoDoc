require 'rails_helper'

RSpec.describe 'Navbar', type: :request do
  let(:user) { create(:user) }

  def sign_in
    post session_path, params: { email_address: user.email_address, password: 'password123' }
  end

  shared_examples 'a responsive, theme-aware navbar' do
    it 'renders the navbar burger for mobile' do
      expect(response.body).to include('navbar-burger')
    end

    it 'sets the navbar Stimulus controller' do
      expect(response.body).to include('data-controller="navbar"')
    end

    it 'wires the burger click action to the Stimulus toggle' do
      expect(response.body).to include('data-action="click->navbar#toggle"')
    end

    it 'does not apply the hardcoded is-light modifier' do
      expect(response.body).not_to match(/class="navbar[^"]*is-light/)
    end

    it 'renders the navbar-menu with a Stimulus target' do
      expect(response.body).to include('data-navbar-target="menu"')
    end
  end

  describe 'unauthenticated layout' do
    context 'when visiting a page other than sign-in' do
      before { get new_user_path }

      it_behaves_like 'a responsive, theme-aware navbar'

      it 'shows the sign-in link' do
        expect(response.body).to include('Sign In')
      end

      it 'shows the sign-up link' do
        expect(response.body).to include('Sign Up')
      end
    end

    context 'when on the sign-in page' do
      before { get login_path }

      it_behaves_like 'a responsive, theme-aware navbar'

      it 'does not render the sign-in link' do
        expect(response.body).not_to include("href=\"#{login_path}\"")
      end

      it 'still shows the sign-up link' do
        expect(response.body).to include('Sign Up')
      end
    end
  end

  describe 'authenticated layout' do
    before do
      sign_in
      get patients_path
    end

    it_behaves_like 'a responsive, theme-aware navbar'

    it 'shows a sign-out button' do
      expect(response.body).to include('Sign Out')
    end
  end
end
