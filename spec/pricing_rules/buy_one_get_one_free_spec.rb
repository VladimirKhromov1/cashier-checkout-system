require 'spec_helper'

RSpec.describe PricingRule::BuyOneGetOneFree do
  let(:gr1) { Catalog.find('GR1') }
  let(:rule) { PricingRule::BuyOneGetOneFree.new(product_code: 'GR1') }

  describe '#initialize' do
    it 'inherits from PricingRule::Base' do
      expect(rule).to be_a(PricingRule::Base)
    end

    context 'freeze protection' do
      it 'freezes the instance after initialization' do
        rule = PricingRule::BuyOneGetOneFree.new(product_code: 'GR1')
        expect(rule).to be_frozen
      end
    end
  end

  describe '#total_price_in_pence' do
    # 1 item = pay for 1 = 1 * 311 = 311
    it 'charges full price for 1 item' do
      expect(rule.total_price_in_pence(gr1, 1)).to eq(311)
    end

    # 2 items = pay for 1 = 1 * 311 = 311
    it 'charges for 1 when buying 2' do
      expect(rule.total_price_in_pence(gr1, 2)).to eq(311)
    end

    # 3 items = pay for 2 = 2 * 311 = 622
    it 'charges for 2 when buying 3' do
      expect(rule.total_price_in_pence(gr1, 3)).to eq(622)
    end

    # 4 items = pay for 2 = 2 * 311 = 622
    it 'charges for 2 when buying 4' do
      expect(rule.total_price_in_pence(gr1, 4)).to eq(622)
    end

    # 5 items = pay for 3 = 3 * 311 = 933
    it 'charges for 3 when buying 5' do
      expect(rule.total_price_in_pence(gr1, 5)).to eq(933)
    end

    # 0 items = pay for 0 = 0 * 311 = 0
    it 'handles zero quantity' do
      expect(rule.total_price_in_pence(gr1, 0)).to eq(0)
    end
  end
end