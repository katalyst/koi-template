# frozen_string_literal: true

RSpec.shared_context "with admin session" do
  let(:session_for) { respond_to?(:admin) ? admin : create(:admin) }

  before do
    next if session_for.blank?

    post admin_session_path, params: { admin: { email: session_for.email, password: session_for.password } }

    next if session_for.otp.blank?

    post admin_session_path, params: { admin: { token: session_for.otp.now } }
  end
end

RSpec.shared_examples "requires admin" do
  let(:session_for) { nil }

  it "redirects to admin login" do
    action
    expect(response).to redirect_to(new_admin_session_path)
  end
end
