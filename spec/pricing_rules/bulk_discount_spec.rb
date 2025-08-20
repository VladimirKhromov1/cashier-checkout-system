require 'spec_helper'

RSpec.describe PricingRule::BulkDiscount do
  subject(:rule) { described_class.new(product_code: 'SR1', min_quantity: 3, discounted_price_in_pence: 450) }

  let(:sr1) { Catalog.find('SR1') }

  describe '#initialize' do
    it 'inherits from PricingRule::Base' do
      expect(rule).to be_a(PricingRule::Base)
    end

    it 'is frozen' do
      expect(rule).to be_frozen
    end

    context 'with validations' do
      context 'for min_quantity' do
        it 'raises error if not an integer' do
          expect { described_class.new(product_code: 'SR1', min_quantity: 'invalid', discounted_price_in_pence: 450) }
            .to raise_error(ArgumentError, 'Minimum quantity must be an Integer')
        end

        it 'raises error if not positive' do
          expect { described_class.new(product_code: 'SR1', min_quantity: 0, discounted_price_in_pence: 450) }
            .to raise_error(ArgumentError, 'Minimum quantity must be positive')
        end
      end

      context 'for discounted_price_in_pence' do
        it 'raises error if not an integer' do
          expect { described_class.new(product_code: 'SR1', min_quantity: 3, discounted_price_in_pence: 'invalid') }
            .to raise_error(ArgumentError, 'Discounted price must be an Integer')
        end

        it 'raises error if not positive' do
          expect { described_class.new(product_code: 'SR1', min_quantity: 3, discounted_price_in_pence: 0) }
            .to raise_error(ArgumentError, 'Discounted price must be positive')
        end
      end
    end
  end

  describe '#total_price' do
    context 'when quantity is below threshold' do
      # 1 item = regular price = 1 * 500 = 500
      it 'charges regular price for 1 item' do
        expect(rule.total_price(sr1, 1)).to eq(500)
      end

      # 2 items = regular price = 2 * 500 = 1000
      it 'charges regular price for 2 items' do
        expect(rule.total_price(sr1, 2)).to eq(1000)
      end
    end

    context 'when quantity meets or exceeds threshold' do
      # 3 items = discount price = 3 * 450 = 1350
      it 'applies bulk discount for 3 items' do
        expect(rule.total_price(sr1, 3)).to eq(1350)
      end

      # 4 items = discount price = 4 * 450 = 1800
      it 'applies bulk discount for 4 items' do
        expect(rule.total_price(sr1, 4)).to eq(1800)
      end
    end
  end
end