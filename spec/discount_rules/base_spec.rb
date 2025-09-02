# frozen_string_literal: true

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
            .to raise_error(ArgumentError, 'Product code must be a String')
        end
      end

      context 'when empty or whitespace' do
        let(:product_code) { '   ' }

        it 'raises ArgumentError' do
          expect { discount_rule }
            .to raise_error(ArgumentError, 'Product code cannot be empty')
        end
      end
    end
  end

  describe '#applies_to?' do
    let(:green_tea_code) { 'GR1' }
    let(:strawberries_code) { 'SR1' }

    context 'when product matches rule' do
      it 'returns true' do
        expect(discount_rule.applies_to?(product_code: green_tea_code)).to be true
      end
    end

    context 'when product does not match rule' do
      it 'returns false' do
        expect(discount_rule.applies_to?(product_code: strawberries_code)).to be false
      end
    end
  end

  describe '#total_amount' do
    let(:green_tea_price) { 311 }
    let(:quantity) { 1 }

    it 'raises NotImplementedError as base implementation' do
      expect { discount_rule.total_amount(original_amount: green_tea_price, quantity: quantity) }
        .to raise_error(NotImplementedError, /must be implemented in the subclasses/)
    end
  end
end