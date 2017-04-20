require 'spec_helper'

RSpec.describe Spree::LineItem do

  context "#save" do
    it "should create one link for a single digital Variant" do
      digital_variant = create(:variant, :digitals => [create(:digital)])
      line_item = create(:line_item, :variant => digital_variant)
      links = digital_variant.digitals.first.digital_links
      expect(links.to_a.size).to eq(1)
      expect(links.first.line_item).to eq(line_item)
    end

    it "should create a link for each quantity of a digital Variant, even when quantity changes later" do
      digital_variant = create(:variant, :digitals => [create(:digital)])
      line_item = create(:line_item, :variant => digital_variant, :quantity => 5)
      links = digital_variant.digitals.first.digital_links
      expect(links.to_a.size).to eq(5)
      links.each { |link| expect(link.line_item).to eq(line_item) }

      # quantity update
      line_item.quantity = 8
      line_item.save
      links = digital_variant.digitals.first.reload.digital_links
      expect(links.to_a.size).to eq(8)
      links.each { |link| expect(link.line_item).to eq(line_item) }
    end

    it "should create a link for each digital of a digital Variant" do
      digital_variant = create(:variant, digitals: create_list(:digital, 3))
      line_item = build(:line_item, variant: digital_variant, quantity: 2)

      expect do
        line_item.save
      end.to change(Spree::DigitalLink, :count).by(+6)

      links = Spree::DigitalLink.last(6)
      expect(links.map(&:line_item_id)).to all(eql(line_item.id))
      expect(links.map(&:digital_id)).to match_array(line_item.variant.digitals.map(&:id) * 2)
    end
  end

  context "#destroy" do
    it "should destroy associated links when destroyed" do
      digital_variant = create(:variant, :digitals => [create(:digital)])
      line_item = create(:line_item, :variant => digital_variant)
      links = digital_variant.digitals.first.digital_links
      expect(links.to_a.size).to eq(1)
      expect(links.first.line_item).to eq(line_item)
      expect {
        line_item.destroy
      }.to change(Spree::DigitalLink, :count).by(-1)
    end
  end
end




