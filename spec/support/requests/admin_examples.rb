# frozen_string_literal: true

RSpec.shared_context "with admin session" do
  let(:session_for) { respond_to?(:admin) ? admin : create(:admin_user) }

  before { create_admin_session(session_for) }

  def create_admin_session(admin)
    return if admin.blank?

    post admin_session_path, params: { admin: { email: admin.email, password: admin.password } }

    return if admin.otp.blank?

    post admin_session_path, params: { admin: { token: admin.otp.now } }
  end
end

RSpec.shared_examples "requires admin" do
  def create_admin_session(_)
    nil # no-op, skip session creation
  end

  it "redirects to admin login" do
    action
    expect(response).to redirect_to(new_admin_session_path)
  end
end

RSpec.shared_context "with bearer token authentication" do
  def create_admin_session(_)
    nil # no-op, skip session creation
  end

  def headers
    device_authorization = session_for.device_authorizations.create!(attributes_for(:admin_device_authorization))
    { "Authorization" => "Bearer #{device_authorization.generate_token_for(:api_access)}" }
  end
end
