require 'spec_helper'

RSpec.describe DiscountRules::Base do
  subject(:discount_rule) { described_class.new(product_code: product_code) }

  let(:product_code) { 'GR1' }

  describe '#initialize' do
    context 'when product code is valid' do
      it 'sets the product code' do
        expect(discount_rule.product_code).to eq('GR1')
      end
    end

    context 'when product code is invalid' do
      context 'when not a string' do
        let(:product_code) { 123 }

        it 'raises ArgumentError' do
          expect { discount_rule }
            .to raise_error(ArgumentError, 'Product code for rule must be a String')
        end
      end

      context 'when empty or whitespace' do
        let(:product_code) { '   ' }

        it 'raises ArgumentError' do
          expect { discount_rule }
            .to raise_error(ArgumentError, 'Product code for rule cannot be empty')
        end
      end

      context 'when product does not exist in catalog' do
        let(:product_code) { 'UNKNOWN' }

        it 'raises ArgumentError with helpful message' do
          known_products = Catalog::PRODUCTS.keys.join(', ')
          expected_message = "Rule cannot be created for unknown product: 'UNKNOWN'. Known products: #{known_products}"

          expect { discount_rule }
            .to raise_error(ArgumentError, expected_message)
        end
      end
    end
  end

  describe '#applies_to?' do
    let(:green_tea) { Catalog.find_product(product_code: 'GR1') }
    let(:strawberries) { Catalog.find_product(product_code: 'SR1') }

    context 'when product matches rule product code' do
      it 'returns true' do
        expect(discount_rule.applies_to?(product: green_tea)).to be true
      end
    end

    context 'when product does not match rule product code' do
      it 'returns false' do
        expect(discount_rule.applies_to?(product: strawberries)).to be false
      end
    end
  end

  describe '#total_amount' do
    let(:product) { Catalog.find_product(product_code: 'GR1') }
    let(:quantity) { 1 }

    it 'raises NotImplementedError as base implementation' do
      expect { discount_rule.total_amount(product: product, quantity: quantity) }
        .to raise_error(NotImplementedError, /must be implemented in the subclasses/)
    end
  end
end