require 'spec_helper'

RSpec.describe PricingRule::Base do
  describe '#initialize' do
    it 'initializes with valid product code using keyword argument' do
      rule = PricingRule::Base.new(product_code: 'GR1')
      expect(rule.product_code).to eq('GR1')
    end

    context 'validations' do
      it 'validates product code is a string' do
        expect { PricingRule::Base.new(product_code: 123) }
          .to raise_error(ArgumentError, 'Product code for rule must be a String')
      end

      it 'validates product code is not empty' do
        expect { PricingRule::Base.new(product_code: '   ') }
          .to raise_error(ArgumentError, 'Product code for rule cannot be empty')
      end

      it 'raises error for unknown product code' do
        known_products = Catalog::PRODUCTS.keys.join(', ')
        expected_message = "Rule cannot be created for unknown product: 'UNKNOWN'. Known products: #{known_products}"

        expect { PricingRule::Base.new(product_code: 'UNKNOWN') }
          .to raise_error(ArgumentError, expected_message)
      end
    end
  end

  describe '#applies_to?' do
    let(:rule) { PricingRule::Base.new(product_code: 'GR1') }
    let(:gr1) { Catalog.find('GR1') }
    let(:sr1) { Catalog.find('SR1') }

    it 'returns true for matching product' do
      expect(rule.applies_to?(gr1)).to be true
    end

    it 'returns false for non-matching product' do
      expect(rule.applies_to?(sr1)).to be false
    end
  end

  describe '#total_price_in_pence' do
    let(:rule) { PricingRule::Base.new(product_code: 'GR1') }
    let(:product) { Catalog.find('GR1') }

    it 'raises NotImplementedError' do
      expect { rule.total_price_in_pence(product, 1) }
        .to raise_error(NotImplementedError, /must be implemented in the subclasses/)
    end
  end
end