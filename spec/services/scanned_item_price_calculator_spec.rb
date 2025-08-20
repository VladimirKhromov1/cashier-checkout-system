require 'spec_helper'

RSpec.describe ScannedItemPriceCalculator do
  describe '#call' do
    let(:bogof_rule) { PricingRule::BuyOneGetOneFree.new('GR1') }
    let(:bulk_rule) { PricingRule::BulkDiscount.new('SR1', min_quantity: 3, discounted_price_in_pence: 450) }
    let(:alternative_rule) { PricingRule::BulkDiscount.new('GR1', min_quantity: 2, discounted_price_in_pence: 280) }

    context 'when no applicable rules' do
      it 'returns regular price calculation' do
        calculator = ScannedItemPriceCalculator.new(
          product_code: 'GR1',
          quantity: 2,
          rules: []
        )

        expect(calculator.call).to eq(622) # 311 * 2
      end
    end

    context 'when single rule applies' do
      it 'calculates discounted price with BOGOF rule' do
        calculator = ScannedItemPriceCalculator.new(
          product_code: 'GR1',
          quantity: 3,
          rules: [bogof_rule]
        )

        expect(calculator.call).to eq(622) # pay for 2 items: 311 * 2
      end

      it 'calculates bulk discounted price' do
        calculator = ScannedItemPriceCalculator.new(
          product_code: 'SR1',
          quantity: 3,
          rules: [bulk_rule]
        )

        expect(calculator.call).to eq(1350) # 450 * 3
      end
    end

    context 'when multiple rules apply to the same product' do
      it 'chooses the most beneficial rule for customer' do
        calculator = ScannedItemPriceCalculator.new(
          product_code: 'GR1',
          quantity: 4,
          rules: [alternative_rule, bogof_rule]
        )

        # BOGOF: pay for 2 items = 622 pence
        # Bulk: pay 280 * 4 = 1120 pence
        # Should choose BOGOF as it's cheaper
        expect(calculator.call).to eq(622)
      end
    end
  end
end