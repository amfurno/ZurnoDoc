RSpec.shared_context 'with authenticated controller' do
  let(:user) { create(:user) }
  let(:session_record) { create(:session, user: user) }

  before do
    allow(controller).to receive(:resume_session) do
      Current.session = session_record
    end
  end
end

# Pass a lambda for params when the index action requires them, e.g.:
#   include_examples 'it redirects unauthenticated requests', -> { { patient_id: patient.to_param } }
RSpec.shared_examples 'it redirects unauthenticated requests' do |params = {}|
  describe 'unauthenticated access' do
    before { allow(controller).to receive(:resume_session).and_call_original }

    it 'redirects to sign-in when not authenticated' do
      resolved_params = params.respond_to?(:call) ? instance_exec(&params) : params
      get :index, params: resolved_params
      expect(response).to redirect_to(login_path)
    end
  end
end
