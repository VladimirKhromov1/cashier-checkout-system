require 'spec_helper'

RSpec.describe Catalog do
  describe '.find' do
    subject(:find_product) { described_class.find(product_code) }

    context 'when the product exists' do
      let(:product_code) { 'GR1' }

      it 'returns the correct product instance' do
        product = find_product
        expect(product).to be_a(Product)
        expect(product.code).to eq('GR1')
        expect(product.name).to eq('Green tea')
        expect(product.price_in_pence).to eq(311)
        expect(product.currency).to eq('GBP')
      end

      it 'returns a frozen product object' do
        expect(find_product).to be_frozen
      end
    end

    context 'when the product does not exist' do
      let(:product_code) { 'UNKNOWN' }

      it 'returns nil' do
        expect(find_product).to be_nil
      end
    end
  end

  describe '.exists?' do
    subject(:product_exists) { described_class.exists?(product_code) }

    context 'when the product exists' do
      let(:product_code) { 'GR1' }

      it 'returns true' do
        expect(product_exists).to be true
      end
    end

    context 'when the product does not exist' do
      let(:product_code) { 'UNKNOWN' }

      it 'returns false' do
        expect(product_exists).to be false
      end
    end
  end
end