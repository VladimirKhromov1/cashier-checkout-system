require_relative '../../lib/services/scanned_item_price_calculator'
require_relative '../../lib/catalog'
require_relative '../../lib/product'
require_relative '../../lib/pricing_rules/buy_one_get_one_free'
require_relative '../../lib/pricing_rules/bulk_discount'

RSpec.describe ScannedItemPriceCalculator do
  describe '#call' do
    let(:bogof_rule) { BuyOneGetOneFree.new('GR1') }
    let(:bulk_rule) { BulkDiscount.new('SR1', min_quantity: 3, discounted_price_in_pence: 450) }

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
  end
end