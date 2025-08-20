require 'spec_helper'

RSpec.describe Catalog do
  describe '.find_product' do
    subject(:find_product) { described_class.find_product(product_code: product_code) }

    context 'when the product exists' do
      let(:product_code) { 'GR1' }

      it 'returns a Product instance' do
        expect(find_product).to be_a(Product)
      end

      it 'returns the product with correct attributes' do
        expect(find_product).to have_attributes(
          code: 'GR1',
          name: 'Green tea',
          amount: 311,
          currency: 'GBP'
        )
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

  describe '.product_exists?' do
    subject(:product_exists) { described_class.product_exists?(product_code: product_code) }

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