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

    context 'with custom pricing rules' do
      let(:pricing_rules) do
        [
          PricingRule::BulkDiscount.new(product_code: 'GR1', min_quantity: 5, discounted_price_in_pence: 250),
          PricingRule::FractionalDiscount.new(product_code: 'SR1', min_quantity: 2, numerator: 1, denominator: 2),
          PricingRule::BuyOneGetOneFree.new(product_code: 'CF1')
        ]
      end

      it 'applies a custom bulk discount for Green Tea' do
        5.times { checkout.scan(gr1) }
        # Custom rule: 5 * 250 = 1250p
        expect(checkout.total).to eq('£12.50')
      end

      it 'applies a 50% discount for Strawberries' do
        3.times { checkout.scan(sr1) }
        # Custom fractional: (3 * 500 * 1/2).round = 750p
        expect(checkout.total).to eq('£7.50')
      end

      it 'applies BOGOF for Coffee' do
        3.times { checkout.scan(cf1) }
        # BOGOF: pay for 2 items = 2 * 1123 = 2246p
        expect(checkout.total).to eq('£22.46')
      end

      it 'applies the best rule for each product in a mixed cart' do
        3.times { checkout.scan(gr1) } # Below threshold for bulk, so 3 * 311 = 933p
        2.times { checkout.scan(sr1) } # 50% discount: (2 * 500 * 1/2).round = 500p
        4.times { checkout.scan(cf1) } # BOGOF: pay for 2 = 2 * 1123 = 2246p
        # Total: 933 + 500 + 2246 = 3679p
        expect(checkout.total).to eq('£36.79')
      end
    end

    context 'with competing pricing rules for the same product' do
      let(:pricing_rules) do
        [
          PricingRule::BuyOneGetOneFree.new(product_code: 'GR1'),
          PricingRule::BulkDiscount.new(product_code: 'GR1', min_quantity: 5, discounted_price_in_pence: 150),
          PricingRule::FractionalDiscount.new(product_code: 'GR1', min_quantity: 3, numerator: 9, denominator: 10) # 10% off
        ]
      end

      context 'with 4 items' do
        it 'chooses the cheapest rule (BOGOF)' do
          4.times { checkout.scan(gr1) }
          # BOGOF: 2 * 311 = 622p <- Cheapest
          # Bulk: N/A
          # Fractional 10% off: (4 * 311 * 9/10).round = 1120p
          expect(checkout.total).to eq('£6.22')
        end
      end

      context 'with 6 items' do
        it 'chooses the cheapest rule (Bulk Discount)' do
          6.times { checkout.scan(gr1) }
          # BOGOF: 3 * 311 = 933p
          # Bulk: 6 * 150 = 900p <- Cheapest
          # Fractional 10% off: (6 * 311 * 9/10).round = 1679p
          expect(checkout.total).to eq('£9.00')
        end
      end
    end
  end
end