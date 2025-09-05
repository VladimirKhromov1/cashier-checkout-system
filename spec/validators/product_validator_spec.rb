# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProductValidator do
  subject(:product_validator) { described_class.new(product: product) }

  describe '#validate!' do
    context 'when the scanned item is a valid canonical product' do
      let(:product) { Catalog.find_product(product_code: 'GR1') }

      it 'does not raise an error' do
        expect { product_validator.validate! }.not_to raise_error
      end
    end

    context 'when the scanned item is not a Product object' do
      let(:product) { 'not_a_product' }

      it 'raises an ArgumentError' do
        expect { product_validator.validate! }
          .to raise_error(ArgumentError, 'Item must be a Product object, got: String')
      end
    end

    context 'when the scanned product code does not exist in the Catalog' do
      let(:product) { Product.new(code: 'INVALID', name: 'Invalid Product', amount: 999, currency: 'GBP') }

      it 'raises an ArgumentError with a specific message' do
        known_products = Catalog::PRODUCTS.keys.join(', ')
        expected_message = "Product with code 'INVALID' does not exist in the Catalog. Known products: #{known_products}"
        
        expect { product_validator.validate! }
          .to raise_error(ArgumentError, expected_message)
      end
    end

    context 'when the scanned item has matching attributes' do
      let(:product) { Product.new(code: 'GR1', name: 'Green tea', amount: 311, currency: 'GBP') }

      it 'validates value equality and passes' do
        catalog_product = Catalog.find_product(product_code: 'GR1')
        
        # Same attributes - value equality passes
        expect(product).to have_attributes(
          code: catalog_product.code,
          name: catalog_product.name,
          amount: catalog_product.amount,
          currency: catalog_product.currency
        )
        
        # Different object identity
        expect(product.equal?(catalog_product)).to be false

        # Therefore validation passes
        expect { product_validator.validate! }.not_to raise_error
      end
    end

    context 'when the scanned item has different attributes' do
      let(:product) { Product.new(code: 'GR1', name: 'Green tea', amount: 999, currency: 'GBP') }

      it 'validates value equality and fails' do
        expect { product_validator.validate! }
          .to raise_error(ArgumentError, 'Scanned item for code GR1 does not match canonical product from Catalog')
      end
    end
  end
end