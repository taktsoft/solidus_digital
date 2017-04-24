require 'spec_helper'

RSpec.describe Spree::Order do
  context "contents.add" do
    it "should add digital Variants of quantity 1 to an order" do
      order = create(:order)
      variants = 3.times.map { create(:variant, :digitals => [create(:digital)]) }
      variants.each { |v| order.contents.add(v, 1) }
      expect(order.line_items.first.variant).to eq(variants[0])
      expect(order.line_items.second.variant).to eq(variants[1])
      expect(order.line_items.third.variant).to eq(variants[2])
    end

    it "should handle quantity higher than 1 when adding one specific digital Variant" do
      order = create(:order)
      digital_variant = create(:variant, :digitals => [create(:digital)])
      order.contents.add digital_variant, 3
      expect(order.line_items.first.quantity).to eq(3)
      order.contents.add digital_variant, 2
      expect(order.line_items.first.quantity).to eq(5)
    end
  end

  context "line_item analysis" do
    it "should understand that all products are digital" do
      order = create(:order)
      3.times do
        order.contents.add create(:variant, :digitals => [create(:digital)]), 1
      end
      expect(order.digital?).to be true
      order.contents.add create(:variant, :digitals => [create(:digital)]), 4
      expect(order.digital?).to be true
    end

    it "should understand that not all products are digital" do
      order = create(:order)
      3.times do
        order.contents.add create(:variant, :digitals => [create(:digital)]), 1
      end
      order.contents.add create(:variant), 1 # this is the analog product
      expect(order.digital?).to be false
      order.contents.add create(:variant, :digitals => [create(:digital)]), 4
      expect(order.digital?).to be false
    end
  end

  context '#digital?/#some_digital?' do
    let(:digital_order) {
      order = create(:order)
      variants = 3.times.map { create(:variant, :digitals => [create(:digital)]) }
      variants.each { |v| order.contents.add(v, 1) }
      order
    }

    let(:mixed_order) {
      order = create(:order)
      variants = 2.times.map { create(:variant, :digitals => [create(:digital)]) }
      variants << create(:variant)
      variants.each { |v| order.contents.add(v, 1) }
      order
    }

    let(:non_digital_order) {
      order = create(:order)
      variants = 3.times.map { create(:variant) }
      variants.each { |v| order.contents.add(v, 1) }
      order
    }

    it 'should return true/true for a digital order' do
      expect(digital_order).to be_digital
      expect(digital_order).to be_some_digital
    end

    it 'should return false/true for a mixed order' do
      expect(mixed_order).not_to be_digital
      expect(mixed_order).to be_some_digital
    end

    it 'should return false/false for an exclusively non-digital order' do
      expect(non_digital_order).not_to be_digital
      expect(non_digital_order).not_to be_some_digital
    end
  end

  context '#digital_line_items' do
    let(:digital_order_digitals) { 3.times.map { create(:digital) } }
    let(:digital_order) {
      order = create(:order)
      variants = digital_order_digitals.map { |d| create(:variant, :digitals => [d]) }
      variants.each { |v| order.contents.add(v, 1) }
      order
    }

    let(:mixed_order_digitals) { 2.times.map { create(:digital) } }
    let(:mixed_order) {
      order = create(:order)
      variants = mixed_order_digitals.map { |d| create(:variant, :digitals => [d]) }
      variants << create(:variant)
      variants.each { |v| order.contents.add(v, 1) }
      order
    }

    let(:non_digital_order) {
      order = create(:order)
      variants = 3.times.map { create(:variant) }
      variants.each { |v| order.contents.add(v, 1) }
      order
    }

    it 'should return true/true for a digital order' do
      digital_order_digital_line_items = digital_order.digital_line_items
      expect(digital_order_digital_line_items.size).to eq(digital_order_digitals.size)
      variants = digital_order_digital_line_items.map(&:variant)
      variants.each do |variant|
        expect(variant).to be_digital
      end
      digital_order_digitals.each do |d|
        expect(variants).to include(d.variant)
      end
    end

    it 'should return false/true for a mixed order' do
      mixed_order_digital_line_items = mixed_order.digital_line_items
      expect(mixed_order_digital_line_items.size).to eq(mixed_order_digitals.size)
      variants = mixed_order_digital_line_items.map(&:variant)
      variants.each do |variant|
        expect(variant).to be_digital
      end
      mixed_order_digitals.each do |d|
        expect(variants).to include(d.variant)
      end
    end

    it 'should return an empty set for an exclusively non-digital order' do
      non_digital_order_digital_line_items = non_digital_order.digital_line_items
      expect(non_digital_order.digital_line_items).to be_empty
    end
  end

  context '#digital_links' do
    let(:mixed_order_digitals) { 2.times.map { create(:digital) } }
    let(:mixed_order) {
      order = create(:order)
      variants = mixed_order_digitals.map { |d| create(:variant, :digitals => [d]) }
      variants << create(:variant)
      variants.each { |v| order.contents.add(v, 1) }
      order
    }

    it 'correctly loads the links' do
      mixed_order_digital_links = mixed_order.digital_links
      links_from_digitals = mixed_order_digitals.map(&:reload).map(&:digital_links).flatten
      expect(mixed_order_digital_links.size).to eq(links_from_digitals.size)
      mixed_order_digital_links.each do |l|
        expect(links_from_digitals).to include(l)
      end
    end
  end

  context '#reset_digital_links!' do
    let!(:order) { build(:order) }
    let!(:link_1) { double }
    let!(:link_2) { double }

    before do
      expect(link_1).to receive(:reset!)
      expect(link_2).to receive(:reset!)
      expect(order).to receive(:digital_links).and_return([link_1, link_2])
    end

    it 'should call reset on the links' do
      order.reset_digital_links!
    end
  end

  describe "after save" do
    context "when complete" do
      subject(:complete_order) { create(:order, state: 'complete') }
      let(:digital_variants) { create_list(:variant, 2, digitals: create_list(:digital, 1)) }
      let(:other_variant) { create(:variant) }
      let(:digital_line_item1) { build(:line_item, variant: digital_variants.first, quantity: 4) }
      let(:digital_line_item2) { build(:line_item, variant: digital_variants.second, quantity: 1) }
      let(:other_line_item) { build(:line_item, variant: other_variant, quantity: 3) }

      before(:each) do
        complete_order.line_items << digital_line_item1
        complete_order.line_items << digital_line_item2
        complete_order.line_items << other_line_item
      end

      it "creates digital_links for digital_items when missing" do
        expect(digital_line_item1).to receive(:create_digital_links).and_call_original
        expect(digital_line_item2).to receive(:create_digital_links).and_call_original
        expect(other_line_item).not_to receive(:create_digital_links)

        expect do
          complete_order.save!
        end.to change(Spree::DigitalLink, :count).by(+5)
      end

      it "recreates digital_links for digital_items when quantity has changed" do
        # create digital_links initially
        complete_order.save!

        complete_order.digital_line_items.second.update!(quantity: 3)

        expect(digital_line_item2).to receive(:create_digital_links).and_call_original
        expect(digital_line_item1).not_to receive(:create_digital_links)
        expect(other_line_item).not_to receive(:create_digital_links)

        expect do
          complete_order.save!
        end.to change(Spree::DigitalLink, :count).by(+2) # 3 - 1
      end

      it "does not change digital_links when correct amount of digital_links already exists" do
        # create digital_links initially
        complete_order.save!

        expect(digital_line_item1).not_to receive(:create_digital_links)
        expect(digital_line_item2).not_to receive(:create_digital_links)
        expect(other_line_item).not_to receive(:create_digital_links)

        expect do
          complete_order.save!
        end.not_to change(Spree::DigitalLink, :count)
      end
    end

    context "when incomplete" do
      let(:other_order_states) { Spree::Order.state_machine.states.keys.without(:complete) }
      let(:digital_variants) { create_list(:variant, 2, digitals: create_list(:digital, 1)) }
      subject(:incomplete_order) { create(:order, state: other_order_states.sample) }

      it "does not create digital_links for digital line_items" do
        incomplete_order.line_items << create(:line_item, variant: digital_variants.first)
        incomplete_order.line_items << create(:line_item, variant: digital_variants.second)
        expect(incomplete_order.digital_line_items.count).to eql(2)

        expect do
          incomplete_order.save!
        end.not_to change(Spree::DigitalLink, :count)
      end
    end
  end
end
