# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin login" do
  it "Shows admin login" do
    visit admin_root_path
    expect(page).to have_field("Email")
  end

  context "when logged in" do
    before do
      admin = create(:admin)

      visit admin_root_path

      fill_in "Email", with: admin.email
      click_on "Next"

      fill_in "Password", with: admin.password
      click_on "Next"

      if admin.try(:otp)
        fill_in "Token", with: admin.otp.now
        click_on "Next"
      end
    end

    it "Shows dashboard" do
      expect(page).to have_current_path admin_dashboard_path
    end
  end
end
