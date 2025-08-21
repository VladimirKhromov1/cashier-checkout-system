require 'spec_helper'

RSpec.describe Checkout do
  subject(:checkout) { described_class.new(discount_rules: discount_rules) }

  let(:discount_rules) { [] }
  let(:green_tea) { Catalog.find_product(product_code: 'GR1') }
  let(:strawberries) { Catalog.find_product(product_code: 'SR1') }
  let(:coffee) { Catalog.find_product(product_code: 'CF1') }

  describe '#initialize' do
    context 'with no discount rules provided' do
      subject(:checkout) { described_class.new }

      it 'initializes with an empty basket and default rules' do
        expect(checkout.total).to eq('£0.00')
      end
    end

    context 'with a specific set of discount rules' do
      let(:discount_rules) { [DiscountRules::BuyOneGetOneFree.new(product_code: 'GR1')] }

      before do
        2.times { checkout.scan(product: green_tea) }
      end

      it 'initializes with the given rules and applies them correctly' do
        expect(checkout.total).to eq('£3.11')
      end
    end
  end

  describe '#scan' do
    context 'with a valid product' do
      it 'adds the product to the basket' do
        expect { checkout.scan(product: green_tea) }.not_to raise_error
        expect(checkout.total).to eq('£3.11')
      end
    end

    context 'with an invalid item' do
      it 'raises an error if the item is not a Product' do
        expect { checkout.scan(product: 'not_a_product') }
          .to raise_error(ArgumentError, 'Item must be a Product object, got: String')
      end

      it 'raises an error if the product is not from the catalog' do
        fake_product = Product.new(code: 'GR1', name: 'Green Tea', amount: 999, currency: 'GBP')
        expect { checkout.scan(product: fake_product) }
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

    context 'without any discount rules' do
      before do
        2.times { checkout.scan(product: green_tea) } # 2 * 311 = 622
        checkout.scan(product: strawberries) # 500
      end

      it 'calculates the sum of the product prices' do
        # 311 + 500 + 311 = 1122
        expect(checkout.total).to eq('£11.22')
      end
    end

    context 'with standard discount rules' do
      let(:discount_rules) do
        [
          DiscountRules::BuyOneGetOneFree.new(product_code: 'GR1'),
          DiscountRules::BulkDiscount.new(product_code: 'SR1', required_quantity: 3, discounted_amount: 450),
          DiscountRules::FractionalDiscount.new(product_code: 'CF1', required_quantity: 3, numerator: 2, denominator: 3)
        ]
      end

      context 'calculates test case 1: GR1, SR1, GR1, GR1, CF1' do
        before do
          3.times { checkout.scan(product: green_tea) }
          checkout.scan(product: strawberries)
          checkout.scan(product: coffee)
        end

        it 'returns the correct total' do
          # GR1(3): BOGOF -> pay for 2 = 622
          # SR1(1): regular = 500
          # CF1(1): regular = 1123
          # Total: 622 + 500 + 1123 = 2245
          expect(checkout.total).to eq('£22.45')
        end
      end

      context 'calculates test case 2: GR1, GR1' do
        before do
          2.times { checkout.scan(product: green_tea) }
        end

        it 'returns the correct total' do
          # GR1(2): BOGOF -> pay for 1 = 311
          expect(checkout.total).to eq('£3.11')
        end
      end

      context 'calculates test case 3: SR1, SR1, GR1, SR1' do
        before do
          3.times { checkout.scan(product: strawberries) }
          checkout.scan(product: green_tea)
        end

        it 'returns the correct total' do
          # SR1(3): bulk discount -> 3 * 450 = 1350
          # GR1(1): regular = 311
          # Total: 1350 + 311 = 1661
          expect(checkout.total).to eq('£16.61')
        end
      end

      context 'calculates test case 4: GR1, CF1, SR1, CF1, CF1' do
        before do
          checkout.scan(product: green_tea)
          3.times { checkout.scan(product: coffee) }
          checkout.scan(product: strawberries)
        end

        it 'returns the correct total' do
          # GR1(1): regular = 311
          # CF1(3): fractional discount -> (3 * 1123 * 2/3).round = 2246
          # SR1(1): regular = 500
          # Total: 311 + 2246 + 500 = 3057
          expect(checkout.total).to eq('£30.57')
        end
      end
    end

    context 'with custom discount rules' do
      let(:discount_rules) do
        [
          DiscountRules::BulkDiscount.new(product_code: 'GR1', required_quantity: 5, discounted_amount: 250),
          DiscountRules::FractionalDiscount.new(product_code: 'SR1', required_quantity: 2, numerator: 1, denominator: 2),
          DiscountRules::BuyOneGetOneFree.new(product_code: 'CF1')
        ]
      end

      context 'with 5 Green Tea items for bulk discount' do
        before do
          5.times { checkout.scan(product: green_tea) }
        end

        it 'applies a custom bulk discount for Green Tea' do
          # Custom rule: 5 * 250 = 1250
          expect(checkout.total).to eq('£12.50')
        end
      end

      context 'with 3 Strawberries for fractional discount' do
        before do
          3.times { checkout.scan(product: strawberries) }
        end

        it 'applies a 50% discount for Strawberries' do
          # Custom fractional: (3 * 500 * 1/2).round = 750
          expect(checkout.total).to eq('£7.50')
        end
      end

      context 'with 3 Coffee items for BOGOF' do
        before do
          3.times { checkout.scan(product: coffee) }
        end

        it 'applies BOGOF for Coffee' do
          # BOGOF: pay for 2 items = 2 * 1123 = 2246
          expect(checkout.total).to eq('£22.46')
        end
      end

      context 'with multiple mixed items with custom rules' do
        before do
          3.times { checkout.scan(product: green_tea) } # Below threshold for bulk, so 3 * 311 = 933
          2.times { checkout.scan(product: strawberries) } # 50% discount: (2 * 500 * 1/2).round = 500
          4.times { checkout.scan(product: coffee) } # BOGOF: pay for 2 = 2 * 1123 = 2246
        end

        it 'applies custom rules to each product type' do
          # Total: 933 + 500 + 2246 = 3679
          expect(checkout.total).to eq('£36.79')
        end
      end
    end

    context 'with competing discount rules for the same product' do
      let(:discount_rules) do
        [
          DiscountRules::BuyOneGetOneFree.new(product_code: 'GR1'),
          DiscountRules::BulkDiscount.new(product_code: 'GR1', required_quantity: 5, discounted_amount: 150),
          DiscountRules::FractionalDiscount.new(product_code: 'GR1', required_quantity: 3, numerator: 9, denominator: 10) # 10% off
        ]
      end

      context 'with 4 items' do
        before do
          4.times { checkout.scan(product: green_tea) }
        end

        it 'chooses the cheapest rule (BOGOF)' do
          # BOGOF: 2 * 311 = 622 <- Cheapest
          # Bulk: N/A
          # Fractional 10% off: (4 * 311 * 9/10).round = 1120
          expect(checkout.total).to eq('£6.22')
        end
      end

      context 'with 6 items' do
        before do
          6.times { checkout.scan(product: green_tea) }
        end

        it 'chooses the cheapest rule (Bulk Discount)' do
          # BOGOF: 3 * 311 = 933
          # Bulk: 6 * 150 = 900 <- Cheapest
          # Fractional 10% off: (6 * 311 * 9/10).round = 1679
          expect(checkout.total).to eq('£9.00')
        end
      end
    end
  end
end