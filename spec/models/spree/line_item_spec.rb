require 'spec_helper'

RSpec.describe Spree::LineItem do
  let(:digitals) { create_list(:digital, 1) }
  let(:digital_variant) { create(:variant, digitals: digitals) }

  let(:complete_order) { create(:order, state: 'complete') }

  context "#create_digital_links" do
    context "when line_item is not persisted" do
      it "raises an error and does not create digital_links" do
        line_item = build(:line_item, order: complete_order, variant: digital_variant, quantity: 1)
        expect(line_item).not_to be_persisted

        expect do
          line_item.create_digital_links
        end.to raise_error(/Missing line_item id!/)
      end
    end

    context "when line_item has unpersisted changes" do
      it "raises an error and does not create digital_links" do
        line_item = create(:line_item, order: complete_order, variant: digital_variant, quantity: 5)
        line_item.quantity = 8
        expect(line_item.changes).to be_present

        expect do
          line_item.create_digital_links
        end.to raise_error(/Unpersisted line_item changes!/)
      end
    end

    context "when order is is incomplete" do
      it "raises an error and does not create digital_links" do
        other_order_states = Spree::Order.state_machine.states.keys.without(:complete)
        incomplete_order = create(:order, state: other_order_states.sample)
        line_item = create(:line_item, order: incomplete_order, variant: digital_variant, quantity: 1)
        expect(line_item.order).not_to be_complete

        expect do
          line_item.create_digital_links
        end.to raise_error(/Order not complete!/)
      end
    end

    context "when digital_links already exist" do
      it "raises an error and does not overwrite digital_links" do
        line_item = create(:line_item, order: complete_order, variant: digital_variant, quantity: 1)
        line_item.create_digital_links
        expect(line_item.digital_links).not_to be_empty

        expect do
          line_item.create_digital_links
        end.to raise_error(/Digital links already present!/)
      end
    end

    context "when order is complete" do
      it "creates one link for a Variant with a single digital" do
        line_item = create(:line_item, order: complete_order, variant: digital_variant, quantity: 1)

        line_item.create_digital_links

        links = digital_variant.digitals.first.digital_links
        expect(links.to_a.size).to eq(1)
        expect(links.first.line_item).to eq(line_item)
      end

      it "creates a link for each quantity of a Variant's digital" do
        line_item = create(:line_item, order: complete_order, variant: digital_variant, quantity: 5)

        line_item.create_digital_links
        links = digital_variant.digitals.first.digital_links
        expect(links.to_a.size).to eq(5)
        links.each { |link| expect(link.line_item).to eq(line_item) }
      end

      it "creates a link for each digital for Variant with multiple digitals" do
        digital_variant = create(:variant, digitals: create_list(:digital, 3))
        line_item = create(:line_item, order: complete_order, variant: digital_variant, quantity: 2)

        expect do
          line_item.create_digital_links
        end.to change(Spree::DigitalLink, :count).by(+6)

        links = Spree::DigitalLink.last(6)
        expect(links.map(&:line_item_id)).to all(eql(line_item.id))
        expect(links.map(&:digital_id)).to match_array(line_item.variant.digitals.map(&:id) * 2)
      end

      it "creates links for the product's master variant's digitals, too" do
        product = create(:product)
        product.master.digitals << create(:digital)
        product.variants << digital_variant
        line_item = create(:line_item, order: complete_order, variant: digital_variant, quantity: 3)

        expect(line_item.variant).not_to eql(product.master)
        expect(product.master).to be_digital
        expect(line_item.variant).to be_digital

        expect do
          line_item.create_digital_links
        end.to change(Spree::DigitalLink, :count).by(+6)

        links = Spree::DigitalLink.last(6)
        expect(links.map(&:line_item_id)).to all(eql(line_item.id))
        expect(links.map(&:digital_id)).to match_array(line_item.variant.digitals.map(&:id) * 3 + [product.master.id] * 3)
      end
    end
  end

  context "#destroy" do
    it "destroys associated links when destroyed" do
      line_item = create(:line_item, order: complete_order, variant: digital_variant)
      line_item.create_digital_links

      links = digital_variant.digitals.first.digital_links
      expect(links.to_a.size).to eq(1)
      expect(links.first.line_item).to eq(line_item)
      expect {
        line_item.destroy
      }.to change(Spree::DigitalLink, :count).by(-1)
    end
  end
end




