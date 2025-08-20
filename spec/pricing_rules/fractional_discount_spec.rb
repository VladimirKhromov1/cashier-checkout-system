require 'spec_helper'

RSpec.describe PricingRule::FractionalDiscount do
  subject(:rule) { described_class.new(product_code: 'CF1', min_quantity: 3, numerator: 2, denominator: 3) }

  let(:cf1) { Catalog.find('CF1') }

  describe '#initialize' do
    it 'inherits from PricingRule::Base' do
      expect(rule).to be_a(PricingRule::Base)
    end

    it 'is frozen' do
      expect(rule).to be_frozen
    end

    context 'with validations' do
      let(:base_params) { { product_code: 'CF1', min_quantity: 3, numerator: 2, denominator: 3 } }

      context 'for min_quantity' do
        it 'raises error if not an integer' do
          params = base_params.merge(min_quantity: 'invalid')
          expect { described_class.new(**params) }.to raise_error(ArgumentError, 'Minimum quantity must be an Integer')
        end

        it 'raises error if not positive' do
          params = base_params.merge(min_quantity: 0)
          expect { described_class.new(**params) }.to raise_error(ArgumentError, 'Minimum quantity must be positive')
        end
      end

      context 'for numerator' do
        it 'raises error if not an integer' do
          params = base_params.merge(numerator: 'invalid')
          expect { described_class.new(**params) }.to raise_error(ArgumentError, 'Numerator must be an Integer')
        end
      end

      context 'for denominator' do
        it 'raises error if not an integer' do
          params = base_params.merge(denominator: 'invalid')
          expect { described_class.new(**params) }.to raise_error(ArgumentError, 'Denominator must be an Integer')
        end
      end

      context 'for ratio' do
        it 'raises error if numerator is not less than denominator' do
          params = base_params.merge(numerator: 5, denominator: 3)
          expect { described_class.new(**params) }
            .to raise_error(ArgumentError, /Numerator .* must be less than denominator .* for a discount rule/)
        end
      end
    end
  end

  describe '#total_price' do
    context 'when quantity is below threshold' do
      # 1 item = regular price = 1 * 1123 = 1123
      it 'charges regular price for 1 item' do
        expect(rule.total_price(cf1, 1)).to eq(1123)
      end

      # 2 items = regular price = 2 * 1123 = 2246
      it 'charges regular price for 2 items' do
        expect(rule.total_price(cf1, 2)).to eq(2246)
      end
    end

    context 'when quantity meets or exceeds threshold' do
      # 3 items = discounted price = 3 * (1123 * 2/3) = 3369 * 2/3 = 2246
      it 'applies fractional discount for 3 items' do
        expect(rule.total_price(cf1, 3)).to eq(2246)
      end

      # 4 items = discounted price = 4 * (1123 * 2/3) = 4492 * 2/3 = 2995
      it 'applies fractional discount for 4 items' do
        expect(rule.total_price(cf1, 4)).to eq(2995)
      end
    end
  end
end