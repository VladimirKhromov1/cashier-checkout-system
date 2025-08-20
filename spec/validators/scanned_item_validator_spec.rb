require 'spec_helper'

RSpec.describe ScannedItemValidator do
  subject(:validator) { described_class.new(product_item: product_item) }

  describe '#validate!' do
    context 'when the scanned item is a valid canonical product' do
      let(:product_item) { Catalog.find('GR1') }

      it 'returns the product' do
        expect(validator.validate!).to eq(product_item)
      end
    end

    context 'when the scanned item is not a Product object' do
      let(:product_item) { 'not_a_product' }

      it 'raises an ArgumentError' do
        expect { validator.validate! }
          .to raise_error(ArgumentError, 'Item must be a Product object, got: String')
      end
    end

    context 'when the scanned item is a Product but not the canonical version from the Catalog' do
      let(:product_item) { Product.new(code: 'GR1', name: 'Fake Green Tea', price_in_pence: 311, currency: 'GBP') }

      it 'raises an ArgumentError' do
        expect { validator.validate! }
          .to raise_error(ArgumentError, 'Scanned item for code GR1 is not the canonical product from Catalog')
      end
    end
  end
end