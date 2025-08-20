require 'spec_helper'

RSpec.describe DiscountRules::BuyOneGetOneFree do
  subject(:rule) { described_class.new(product_code: 'GR1') }

  let(:green_tea) { Catalog.find_product(product_code: 'GR1') }

  describe '#initialize' do
    it 'inherits from DiscountRules::Base' do
      expect(rule).to be_a(DiscountRules::Base)
    end

    it 'is frozen' do
      expect(rule).to be_frozen
    end
  end

  describe '#total_amount' do
    context 'with an odd number of items' do
      # 1 item = pay for 1 = 1 * 311 = 311
      it 'charges full price for 1 item' do
        expect(rule.total_amount(product: green_tea, quantity: 1)).to eq(311)
      end

      # 3 items = pay for 2 = 2 * 311 = 622
      it 'charges for 2 when buying 3' do
        expect(rule.total_amount(product: green_tea, quantity: 3)).to eq(622)
      end

      # 5 items = pay for 3 = 3 * 311 = 933
      it 'charges for 3 when buying 5' do
        expect(rule.total_amount(product: green_tea, quantity: 5)).to eq(933)
      end
    end

    context 'with an even number of items' do
      # 2 items = pay for 1 = 1 * 311 = 311
      it 'charges for 1 when buying 2' do
        expect(rule.total_amount(product: green_tea, quantity: 2)).to eq(311)
      end

      # 4 items = pay for 2 = 2 * 311 = 622
      it 'charges for 2 when buying 4' do
        expect(rule.total_amount(product: green_tea, quantity: 4)).to eq(622)
      end
    end

    context 'with zero items' do
      # 0 items = pay for 0 = 0 * 311 = 0
      it 'returns zero' do
        expect(rule.total_amount(product: green_tea, quantity: 0)).to eq(0)
      end
    end
  end
end