# frozen_string_literal: true

require "rails_helper"

RSpec.describe HomepagesController do
  subject { action && response }

  describe "GET /homepage" do
    let(:action) { get root_path }

    it { is_expected.to be_successful }
  end
end
