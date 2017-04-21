require 'spec_helper'

RSpec.describe Spree::Digital do
  subject(:digital) { build(:digital) }

  it "has a valid factory" do
    expect(digital).to be_valid
  end

  context 'validation' do
    it { is_expected.to belong_to(:variant) }
    it { is_expected.to have_attached_file(:attachment) }
    it { is_expected.to validate_attachment_presence(:attachment) }
  end

  describe "attachment" do
    it "does not validate content type" do
      digital.attachment_content_type = "TEST123"
      expect(digital).to be_valid
    end

    it "uses 'private/system' directory for storage" do
      expect(digital.attachment.path).to start_with(File.path(Rails.root + "private" + "system"))
    end
  end

  context "#destroy" do
    it "should destroy associated digital_links" do
      digital = create(:digital)
      3.times { digital.digital_links.create!({ :line_item => create(:line_item) }) }
      expect(Spree::DigitalLink.count).to eq(3)
      expect {
        digital.destroy
      }.to change(Spree::DigitalLink, :count).by(-3)
    end
  end
end

