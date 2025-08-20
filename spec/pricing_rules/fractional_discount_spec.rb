require 'spec_helper'

RSpec.describe PricingRule::FractionalDiscount do
  let(:cf1) { Catalog.find('CF1') }
  let(:rule) { PricingRule::FractionalDiscount.new(product_code: 'CF1', min_quantity: 3, numerator: 2, denominator: 3) }

  describe '#initialize' do
    it 'inherits from PricingRule::Base' do
      expect(rule).to be_a(PricingRule::Base)
    end

    context 'freeze protection' do
      it 'freezes the instance after initialization' do
        rule = PricingRule::FractionalDiscount.new(product_code: 'CF1', min_quantity: 3, numerator: 2, denominator: 3)
        expect(rule).to be_frozen
      end
    end

    context 'validations' do
      it 'validates min_quantity is a positive integer' do
        expect { PricingRule::FractionalDiscount.new(product_code: 'CF1', min_quantity: 'invalid', numerator: 2, denominator: 3) }
          .to raise_error(ArgumentError, 'Minimum quantity must be an Integer')
      end

      it 'validates min_quantity is positive' do
        expect { PricingRule::FractionalDiscount.new(product_code: 'CF1', min_quantity: 0, numerator: 2, denominator: 3) }
          .to raise_error(ArgumentError, 'Minimum quantity must be positive')
      end

      it 'validates numerator is a positive integer' do
        expect { PricingRule::FractionalDiscount.new(product_code: 'CF1', min_quantity: 3, numerator: 'invalid', denominator: 3) }
          .to raise_error(ArgumentError, 'Numerator must be an Integer')
      end

      it 'validates denominator is a positive integer' do
        expect { PricingRule::FractionalDiscount.new(product_code: 'CF1', min_quantity: 3, numerator: 2, denominator: 'invalid') }
          .to raise_error(ArgumentError, 'Denominator must be an Integer')
      end

      it 'validates numerator is less than denominator for discount' do
        expect { PricingRule::FractionalDiscount.new(product_code: 'CF1', min_quantity: 3, numerator: 5, denominator: 3) }
          .to raise_error(ArgumentError, /Numerator .* must be less than denominator .* for a discount rule/)
      end
    end
  end

  describe '#total_price_in_pence' do
    # 1 item = regular price = 1 * 1123 = 1123
    it 'charges regular price for 1 item' do
      expect(rule.total_price_in_pence(cf1, 1)).to eq(1123)
    end

    # 2 items = regular price = 2 * 1123 = 2246
    it 'charges regular price for 2 items' do
      expect(rule.total_price_in_pence(cf1, 2)).to eq(2246)
    end

    # 3 items = discounted price = 3 * (1123 * 2/3) = 3369 * 2/3 = 2246
    it 'applies fractional discount for 3 items' do
      expect(rule.total_price_in_pence(cf1, 3)).to eq(2246)
    end

    # 4 items = discounted price = 4 * (1123 * 2/3) = 4492 * 2/3 = 2995
    it 'applies fractional discount for 4 items' do
      expect(rule.total_price_in_pence(cf1, 4)).to eq(2995)
    end
  end
end