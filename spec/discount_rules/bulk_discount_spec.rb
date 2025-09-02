# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DiscountRules::BulkDiscount do
  subject(:bulk_discount_rule) { described_class.new(product_code: strawberries_code, required_quantity: 3, discounted_amount: 450) }

  let(:strawberries_code) { 'SR1' }

  describe '#initialize' do
    it 'inherits from DiscountRules::Base' do
      expect(bulk_discount_rule).to be_a(DiscountRules::Base)
    end

    it 'is frozen' do
      expect(bulk_discount_rule).to be_frozen
    end

    context 'with validations' do
      context 'for required_quantity' do
        let(:discounted_amount) { 450 }

        it 'raises error if not an integer' do
          expect { described_class.new(product_code: strawberries_code, required_quantity: 'invalid', discounted_amount: discounted_amount) }
            .to raise_error(ArgumentError, 'Required quantity must be an Integer')
        end

        it 'raises error if not positive' do
          expect { described_class.new(product_code: strawberries_code, required_quantity: 0, discounted_amount: discounted_amount) }
            .to raise_error(ArgumentError, 'Required quantity must be positive')
        end
      end

      context 'for discounted_amount' do
        it 'raises error if not an integer' do
          expect { described_class.new(product_code: strawberries_code, required_quantity: 3, discounted_amount: 'invalid') }
            .to raise_error(ArgumentError, 'Discounted amount must be an Integer')
        end

        it 'raises error if not positive' do
          expect { described_class.new(product_code: strawberries_code, required_quantity: 3, discounted_amount: 0) }
            .to raise_error(ArgumentError, 'Discounted amount must be positive')
        end
      end
    end
  end

  describe '#total_amount' do
    let(:strawberries_original_amount) { 500 }

    context 'when quantity is below threshold' do
      # 1 item = regular price = 1 * 500 = 500
      it 'charges regular price for 1 item' do
        expect(bulk_discount_rule.total_amount(original_amount: strawberries_original_amount, quantity: 1)).to eq(500)
      end

      # 2 items = regular price = 2 * 500 = 1000
      it 'charges regular price for 2 items' do
        expect(bulk_discount_rule.total_amount(original_amount: strawberries_original_amount, quantity: 2)).to eq(1000)
      end
    end

    context 'when quantity meets or exceeds threshold' do
      # 3 items = discount price = 3 * 450 = 1350
      it 'applies bulk pricing for 3 items' do
        expect(bulk_discount_rule.total_amount(original_amount: strawberries_original_amount, quantity: 3)).to eq(1350)
      end

      # 4 items = discount price = 4 * 450 = 1800
      it 'applies bulk pricing for 4 items' do
        expect(bulk_discount_rule.total_amount(original_amount: strawberries_original_amount, quantity: 4)).to eq(1800)
      end
    end
  end
end