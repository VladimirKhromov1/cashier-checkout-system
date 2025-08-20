require_relative '../../lib/pricing_rules/bulk_discount'

RSpec.describe PricingRule::BulkDiscount do
  let(:sr1) { Catalog.find('SR1') }
  let(:rule) { PricingRule::BulkDiscount.new('SR1', min_quantity: 3, discounted_price_in_pence: 450) }

  describe '#initialize' do
    it 'inherits from PricingRule::Base' do
      expect(rule).to be_a(PricingRule::Base)
    end
  end

  describe '#total_price_in_pence' do
    # 1 item = regular price = 1 * 500 = 500
    it 'charges regular price for 1 item' do
      expect(rule.total_price_in_pence(sr1, 1)).to eq(500)
    end

    # 2 items = regular price = 2 * 500 = 1000
    it 'charges regular price for 2 items' do
      expect(rule.total_price_in_pence(sr1, 2)).to eq(1000)
    end

    # 3 items = discount price = 3 * 450 = 1350
    it 'applies bulk discount for 3 items' do
      expect(rule.total_price_in_pence(sr1, 3)).to eq(1350)
    end

    # 4 items = discount price = 4 * 450 = 1800
    it 'applies bulk discount for 4 items' do
      expect(rule.total_price_in_pence(sr1, 4)).to eq(1800)
    end
  end
end