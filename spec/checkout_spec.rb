require 'spec_helper'

RSpec.describe Checkout do
  subject(:checkout) { described_class.new(pricing_rules) }

  let(:pricing_rules) { [] }
  let(:gr1) { Catalog.find('GR1') }
  let(:sr1) { Catalog.find('SR1') }
  let(:cf1) { Catalog.find('CF1') }

  describe '#initialize' do
    context 'with no pricing rules provided' do
      subject(:checkout) { described_class.new }

      it 'initializes with an empty basket and default rules' do
        expect(checkout.total).to eq('£0.00')
      end
    end

    context 'with a specific set of pricing rules' do
      let(:pricing_rules) { [PricingRule::BuyOneGetOneFree.new(product_code: 'GR1')] }

      it 'initializes with the given rules' do
        checkout.scan(gr1)
        checkout.scan(gr1)
        expect(checkout.total).to eq('£3.11')
      end
    end
  end

  describe '#scan' do
    context 'with a valid product' do
      it 'adds the product to the basket' do
        expect { checkout.scan(gr1) }.not_to raise_error
        expect(checkout.total).to eq('£3.11')
      end
    end

    context 'with an invalid item' do
      it 'raises an error if the item is not a Product' do
        expect { checkout.scan('not_a_product') }
          .to raise_error(ArgumentError, 'Item must be a Product object, got: String')
      end

      it 'raises an error if the product is not from the catalog' do
        fake_product = Product.new(code: 'GR1', name: 'Fake Green Tea', price_in_pence: 999, currency: 'GBP')
        expect { checkout.scan(fake_product) }
          .to raise_error(ArgumentError, 'Scanned item for code GR1 is not the canonical product from Catalog')
      end
    end
  end

  describe '#total' do
    context 'when the basket is empty' do
      it 'returns £0.00' do
        expect(checkout.total).to eq('£0.00')
      end
    end

    context 'without any pricing rules' do
      before do
        checkout.scan(gr1) # 311p
        checkout.scan(sr1) # 500p
        checkout.scan(gr1) # 311p
      end

      it 'calculates the sum of the product prices' do
        # 311 + 500 + 311 = 1122p
        expect(checkout.total).to eq('£11.22')
      end
    end

    context 'with standard pricing rules' do
      let(:pricing_rules) do
        [
          PricingRule::BuyOneGetOneFree.new(product_code: 'GR1'),
          PricingRule::BulkDiscount.new(product_code: 'SR1', min_quantity: 3, discounted_price_in_pence: 450),
          PricingRule::FractionalDiscount.new(product_code: 'CF1', min_quantity: 3, numerator: 2, denominator: 3)
        ]
      end

      context 'calculates test case 1: GR1, SR1, GR1, GR1, CF1' do
        it 'returns the correct total' do
          [gr1, sr1, gr1, gr1, cf1].each { |item| checkout.scan(item) }
          # GR1(3): BOGOF -> pay for 2 = 622p
          # SR1(1): regular = 500p
          # CF1(1): regular = 1123p
          # Total: 622 + 500 + 1123 = 2245p
          expect(checkout.total).to eq('£22.45')
        end
      end

      context 'calculates test case 2: GR1, GR1' do
        it 'returns the correct total' do
          [gr1, gr1].each { |item| checkout.scan(item) }
          # GR1(2): BOGOF -> pay for 1 = 311p
          expect(checkout.total).to eq('£3.11')
        end
      end

      context 'calculates test case 3: SR1, SR1, GR1, SR1' do
        it 'returns the correct total' do
          [sr1, sr1, gr1, sr1].each { |item| checkout.scan(item) }
          # SR1(3): bulk discount -> 3 * 450 = 1350p
          # GR1(1): regular = 311p
          # Total: 1350 + 311 = 1661p
          expect(checkout.total).to eq('£16.61')
        end
      end

      context 'calculates test case 4: GR1, CF1, SR1, CF1, CF1' do
        it 'returns the correct total' do
          [gr1, cf1, sr1, cf1, cf1].each { |item| checkout.scan(item) }
          # GR1(1): regular = 311p
          # CF1(3): fractional discount -> (3 * 1123 * 2/3).round = 2246p
          # SR1(1): regular = 500p
          # Total: 311 + 2246 + 500 = 3057p
          expect(checkout.total).to eq('£30.57')
        end
      end
    end

    context 'with competing pricing rules for the same product' do
      let(:pricing_rules) do
        [
          PricingRule::BuyOneGetOneFree.new(product_code: 'GR1'),
          PricingRule::FractionalDiscount.new(product_code: 'GR1', min_quantity: 4, numerator: 1, denominator: 3)
        ]
      end

      it 'chooses the most beneficial rule for the customer' do
        4.times { checkout.scan(gr1) }
        # BOGOF: 2 * 311 = 622p
        # Fractional: (4 * 311 * 1/3).round = 415p <- This is cheaper
        expect(checkout.total).to eq('£4.15')
      end
    end
  end
end