# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin login" do
  let!(:admin) { create(:admin) }

  it "Shows admin login" do
    visit admin_root_path
    expect(page).to have_text "Log in"
  end

  it "Allows a admin to login" do
    visit admin_root_path

    fill_in "Email", with: admin.email
    fill_in "Password", with: admin.password
    click_on "Log in"

    expect(page).to have_current_path admin_dashboard_path
  end
end
