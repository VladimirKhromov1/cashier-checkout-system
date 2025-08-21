require 'spec_helper'

RSpec.describe ProductAmountCalculator do
  subject(:calculator) { described_class.new(product_code: product_code, quantity: quantity, rules: rules) }

  let(:product_code) { 'GR1' }
  let(:quantity) { 1 }
  let(:rules) { [] }

  let(:bogof_rule) { DiscountRules::BuyOneGetOneFree.new(product_code: 'GR1') }
  let(:bulk_rule_sr1) { DiscountRules::BulkDiscount.new(product_code: 'SR1', required_quantity: 3, discounted_amount: 450) }
  let(:bulk_rule_gr1) { DiscountRules::BulkDiscount.new(product_code: 'GR1', required_quantity: 2, discounted_amount: 280) }

  describe '#call' do
    context 'when no rules are applicable' do
      let(:quantity) { 2 }

      it 'returns the regular price' do
        # 2 items * 311 pence = 622
        expect(calculator.call).to eq(622)
      end
    end

    context 'when a single rule is applicable' do
      context 'with Buy One Get One Free rule' do
        let(:quantity) { 3 }
        let(:rules) { [bogof_rule] }

        it 'applies the BOGOF rule' do
          # Pay for 2 items: 2 * 311 pence = 622
          expect(calculator.call).to eq(622)
        end
      end

      context 'with Bulk Discount rule' do
        let(:product_code) { 'SR1' }
        let(:quantity) { 3 }
        let(:rules) { [bulk_rule_sr1] }

        it 'applies the bulk discount rule' do
          # 3 items * 450 pence = 1350
          expect(calculator.call).to eq(1350)
        end
      end
    end

    context 'when multiple rules apply' do
      let(:quantity) { 4 }
      let(:rules) { [bulk_rule_gr1, bogof_rule] }

      it 'chooses the most beneficial rule for the customer' do
        # BOGOF: pay for 2 items = 2 * 311 = 622 pence
        # Bulk: pay 4 * 280 = 1120 pence
        # The BOGOF rule is cheaper, so it should be chosen.
        expect(calculator.call).to eq(622)
      end
    end
  end
end