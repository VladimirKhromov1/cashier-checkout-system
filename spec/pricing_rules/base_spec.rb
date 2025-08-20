require_relative '../../lib/pricing_rules/base'

RSpec.describe PricingRule::Base do
  describe '#initialize' do
    it 'initializes with valid product code' do
      rule = PricingRule::Base.new('GR1')
      expect(rule.product_code).to eq('GR1')
    end

    it 'raises error for unknown product code' do
      expect { PricingRule::Base.new('UNKNOWN') }
        .to raise_error(ArgumentError, /Rule cannot be created for unknown product: 'UNKNOWN'/)
    end
  end

  describe '#applies_to?' do
    let(:rule) { PricingRule::Base.new('GR1') }
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
    let(:rule) { PricingRule::Base.new('GR1') }
    let(:product) { Catalog.find('GR1') }

    it 'raises NotImplementedError' do
      expect { rule.total_price_in_pence(product, 1) }
        .to raise_error(NotImplementedError, /must be implemented in the subclasses/)
    end
  end
end