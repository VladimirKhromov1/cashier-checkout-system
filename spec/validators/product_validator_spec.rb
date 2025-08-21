require 'spec_helper'

RSpec.describe ProductValidator do
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

    context 'when the scanned product code does not exist in the Catalog' do
      let(:product) { Product.new(code: 'INVALID', name: 'Invalid Product', amount: 999, currency: 'GBP') }

      it 'raises an ArgumentError with a specific message' do
        expect { validator.validate! }
          .to raise_error(ArgumentError, "Product with code 'INVALID' does not exist in the Catalog")
      end
    end

    context 'when the scanned item is a newly created Product object (not from Catalog)' do
      let(:product) { Product.new(code: 'GR1', name: 'Green tea', amount: 311, currency: 'GBP') }

      it 'validates object identity, not attribute equality' do
        catalog_product = Catalog.find_product(product_code: 'GR1')
        
        # Same attributes - value equality passes
        expect(product).to have_attributes(
          code: catalog_product.code,
          name: catalog_product.name,
          amount: catalog_product.amount,
          currency: catalog_product.currency
        )
        
        # But different object identity - this is what validation catches
        expect(product.equal?(catalog_product)).to be false
        
        # Therefore validation fails
        expect { validator.validate! }
          .to raise_error(ArgumentError, 'Scanned item for code GR1 is not the canonical product from Catalog')
      end
    end
  end
end