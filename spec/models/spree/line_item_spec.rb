require 'spec_helper'

RSpec.describe Spree::LineItem do
  let(:digitals) { create_list(:digital, 1) }
  let(:digital_variant) { create(:variant, digitals: digitals) }

  let(:incomplete_order) { create(:order, state: 'confirm') }
  let(:complete_order) { create(:order, state: 'complete') }

  context "#save" do
    context "when order is is incomplete" do
      it "does not create any link for a Variant with a single digital" do
        expect(digital_variant.digitals.count).to eql(1)

        line_item = create(:line_item, order: incomplete_order, variant: digital_variant, quantity: 1)
        links = digital_variant.digitals.first.digital_links
        expect(links).to be_empty

        line_item.update!(quantity: 3)
        links = digital_variant.digitals.first.digital_links
        expect(links).to be_empty
      end

      it "does not create any link for a Variant with multiple digitals" do
        digital_variant = create(:variant, digitals: create_list(:digital, 3))
        line_item = build(:line_item, order: incomplete_order, variant: digital_variant, quantity: 2)

        # does not create any link on create
        expect(line_item).not_to be_persisted
        expect do
          line_item.save!
        end.not_to change(Spree::DigitalLink, :count).from(0)

        # does not create any link on update
        expect(line_item).to be_persisted
        expect do
          line_item.save!
        end.not_to change(Spree::DigitalLink, :count).from(0)
      end
    end

    context "when order is complete" do
      it "creates one link for a Variant with a single digital" do
        line_item = create(:line_item, order: complete_order, variant: digital_variant, quantity: 1)
        links = digital_variant.digitals.first.digital_links
        expect(links.to_a.size).to eq(1)
        expect(links.first.line_item).to eq(line_item)
      end

      it "creates a link for each quantity of a Variant's digital, even when quantity changes later" do
        line_item = create(:line_item, order: complete_order, variant: digital_variant, quantity: 5)
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

      it "creates a link for each digital for Variant with multiple digitals" do
        digital_variant = create(:variant, digitals: create_list(:digital, 3))
        line_item = build(:line_item, order: complete_order, variant: digital_variant, quantity: 2)

        expect do
          line_item.save!
        end.to change(Spree::DigitalLink, :count).by(+6)

        links = Spree::DigitalLink.last(6)
        expect(links.map(&:line_item_id)).to all(eql(line_item.id))
        expect(links.map(&:digital_id)).to match_array(line_item.variant.digitals.map(&:id) * 2)
      end
    end
  end

  context "#destroy" do
    it "destroys associated links when destroyed" do
      line_item = create(:line_item, order: complete_order, variant: digital_variant)
      links = digital_variant.digitals.first.digital_links
      expect(links.to_a.size).to eq(1)
      expect(links.first.line_item).to eq(line_item)
      expect {
        line_item.destroy
      }.to change(Spree::DigitalLink, :count).by(-1)
    end
  end
end




