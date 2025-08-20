require_relative '../../lib/pricing_rules/fractional_discount'

RSpec.describe PricingRule::FractionalDiscount do
  let(:cf1) { Catalog.find('CF1') }
  let(:rule) { PricingRule::FractionalDiscount.new('CF1', min_quantity: 3, numerator: 2, denominator: 3) }

  describe '#initialize' do
    it 'inherits from PricingRule::Base' do
      expect(rule).to be_a(PricingRule::Base)
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

    # 3 items = discounted price = 3 * (1123 * 2/3) = 3 * 749 = 2247
    it 'applies fractional discount for 3 items' do
      expect(rule.total_price_in_pence(cf1, 3)).to eq(2247)
    end

    # 4 items = discounted price = 4 * (1123 * 2/3) = 4 * 749 = 2996
    it 'applies fractional discount for 4 items' do
      expect(rule.total_price_in_pence(cf1, 4)).to eq(2996)
    end
  end
end