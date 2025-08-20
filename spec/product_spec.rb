require 'spec_helper'

RSpec.describe Product do
  describe '#initialize' do
    it 'creates a product with basic attributes' do
      product = Product.new(code: 'GR1', name: 'Green Tea', price_in_pence: 311, currency: 'GBP')

      expect(product.code).to eq('GR1')
      expect(product.name).to eq('Green Tea')
      expect(product.price_in_pence).to eq(311)
      expect(product.currency).to eq('GBP')
    end

    it 'freezes the product instance' do
      product = Product.new(code: 'GR1', name: 'Green Tea', price_in_pence: 311, currency: 'GBP')
      expect(product).to be_frozen
    end

    it 'validates product code as string' do
      expect { Product.new(code: 123, name: 'Green Tea', price_in_pence: 311, currency: 'GBP') }
        .to raise_error(ArgumentError, 'Product code must be a String')
    end

    it 'validates product name as non-empty string' do
      expect { Product.new(code: 'GR1', name: '   ', price_in_pence: 311, currency: 'GBP') }
        .to raise_error(ArgumentError, 'Product name cannot be empty')
    end

    it 'validates price as positive integer' do
      expect { Product.new(code: 'GR1', name: 'Green Tea', price_in_pence: 0, currency: 'GBP') }
        .to raise_error(ArgumentError, 'Price in pence must be positive')
    end

    it 'validates currency and converts to uppercase' do
      product = Product.new(code: 'GR1', name: 'Green Tea', price_in_pence: 311, currency: 'gbp')
      expect(product.currency).to eq('GBP')
    end
  end
end