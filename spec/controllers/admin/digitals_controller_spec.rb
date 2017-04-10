require 'spec_helper'

RSpec.describe Spree::Admin::DigitalsController do
  stub_authorization!

  let!(:product) { create(:product) }

  context '#index' do
    render_views

    context "with variants" do
      let(:digitals) { 3.times.map { create(:digital) } }
      let(:variants_with_digitals) do
        digitals.map { |d| create(:variant, product: product, digitals: [d]) }
      end
      let(:variants_without_digitals) { 3.times.map { create(:variant, product: product) } }

      xit "should display an empty page when no digitals exist" do
        variants_without_digitals
        spree_get :index, product_id: product.slug
        # FIXME
      end

      xit "should display list of digitals when they exist" do
        # FIXME
      end
    end

    context "without non-master variants" do

      it "should display an empty page when the master variant is not digital" do
        spree_get :index, product_id: product.slug
        expect(response.code).to eq("200")
        expect(response.body).to include("This product has no variants")
        expect(response.body).not_to include('A digital version of this product currently exists')
      end

      it "should display the variant details when the master is digital" do
        @digital = create :digital, :variant => product.master
        spree_get :index, product_id: product.slug
        expect(response.code).to eq("200")
        expect(response.body).to include('A digital version of this product currently exists')
      end

    end
  end

  context '#create' do
    context 'for a product that exists' do
      let!(:variant) { create(:variant, product: product) }

      it 'creates a digital associated with the variant and product' do
        expect {
          spree_post :create, product_id: product.slug,
                              digital: { variant_id: variant.id,
                                         attachment: upload_image('thinking-cat.jpg') }
          expect(response).to redirect_to(spree.admin_product_digitals_path(product))
        }.to change(Spree::Digital, :count).by(1)
      end
    end

    context 'for an invalid object' do
      it 'redirects to the index page' do
        expect {
          spree_post :create, product_id: product.slug, digital: { variant_id: product.master.id } # fail validation by not passing attachment
          expect(response).to redirect_to(spree.admin_product_digitals_path(product))
        }.to change(Spree::Digital, :count).by(0)
      end
    end
  end

  context '#destroy' do
    let(:digital) { create(:digital) }
    let!(:variant) { create(:variant, product: product, digitals: [digital]) }

    context 'for a digital and product that exist' do
      it 'deletes the associated digital' do
        expect {
          spree_delete :destroy, product_id: product.slug, id: digital.id
          expect(response).to redirect_to(spree.admin_product_digitals_path(product))
        }.to change(Spree::Digital, :count).by(-1)
      end
    end
  end
end
