require 'spec_helper'

RSpec.describe DiscountRules::BulkDiscount do
  subject(:rule) { described_class.new(product_code: 'SR1', required_quantity: 3, discounted_amount: 450) }

  let(:sr1) { Catalog.find_product(product_code: 'SR1') }

  describe '#initialize' do
    it 'inherits from DiscountRules::Base' do
      expect(rule).to be_a(DiscountRules::Base)
    end

    it 'is frozen' do
      expect(rule).to be_frozen
    end

    context 'with validations' do
      context 'for required_quantity' do
        it 'raises error if not an integer' do
          expect { described_class.new(product_code: 'SR1', required_quantity: 'invalid', discounted_amount: 450) }
            .to raise_error(ArgumentError, 'Required quantity must be an Integer')
        end

        it 'raises error if not positive' do
          expect { described_class.new(product_code: 'SR1', required_quantity: 0, discounted_amount: 450) }
            .to raise_error(ArgumentError, 'Required quantity must be positive')
        end
      end

      context 'for discounted_amount' do
        it 'raises error if not an integer' do
          expect { described_class.new(product_code: 'SR1', required_quantity: 3, discounted_amount: 'invalid') }
            .to raise_error(ArgumentError, 'Discounted amount must be an Integer')
        end

        it 'raises error if not positive' do
          expect { described_class.new(product_code: 'SR1', required_quantity: 3, discounted_amount: 0) }
            .to raise_error(ArgumentError, 'Discounted amount must be positive')
        end
      end
    end
  end

  describe '#total_amount' do
    context 'when quantity is below threshold' do
      # 1 item = regular price = 1 * 500 = 500
      it 'charges regular price for 1 item' do
        expect(rule.total_amount(product: sr1, quantity: 1)).to eq(500)
      end

      # 2 items = regular price = 2 * 500 = 1000
      it 'charges regular price for 2 items' do
        expect(rule.total_amount(product: sr1, quantity: 2)).to eq(1000)
      end
    end

    context 'when quantity meets or exceeds threshold' do
      # 3 items = discount price = 3 * 450 = 1350
      it 'applies bulk discount for 3 items' do
        expect(rule.total_amount(product: sr1, quantity: 3)).to eq(1350)
      end

      # 4 items = discount price = 4 * 450 = 1800
      it 'applies bulk discount for 4 items' do
        expect(rule.total_amount(product: sr1, quantity: 4)).to eq(1800)
      end
    end
  end
end