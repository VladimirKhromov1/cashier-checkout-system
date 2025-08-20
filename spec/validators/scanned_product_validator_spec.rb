require 'spec_helper'

RSpec.describe ScannedProductValidator do
  subject(:validator) { described_class.new(product: product) }

  describe '#validate!' do
    context 'when the scanned item is a valid canonical product' do
      let(:product) { Catalog.find_product(product_code: 'GR1') }

      it 'returns the product' do
        expect(validator.validate!).to eq(product)
      end
    end

    context 'when the scanned item is not a Product object' do
      let(:product) { 'not_a_product' }

      it 'raises an ArgumentError' do
        expect { validator.validate! }
          .to raise_error(ArgumentError, 'Item must be a Product object, got: String')
      end
    end

    context 'when the scanned item is a Product but not the canonical version from the Catalog' do
      let(:product) { Product.new(code: 'GR1', name: 'Fake Green Tea', amount: 311, currency: 'GBP') }

      it 'raises an ArgumentError' do
        expect { validator.validate! }
          .to raise_error(ArgumentError, 'Scanned item for code GR1 is not the canonical product from Catalog')
      end
    end

    context 'when the scanned product code does not exist in the Catalog' do
      let(:product) { Product.new(code: 'INVALID', name: 'Invalid Product', amount: 999, currency: 'GBP') }

      it 'raises an ArgumentError with a specific message' do
        expect { validator.validate! }
          .to raise_error(ArgumentError, "Product with code 'INVALID' does not exist in the Catalog")
      end
    end
  end
end