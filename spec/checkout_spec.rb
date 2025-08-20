require 'spec_helper'

RSpec.describe Checkout do
  let(:gr1) { Catalog.find('GR1') }
  let(:sr1) { Catalog.find('SR1') }
  let(:cf1) { Catalog.find('CF1') }

  describe '#initialize' do
    it 'initializes with empty pricing rules' do
      checkout = Checkout.new
      expect(checkout.total).to eq('£0.00')
    end

    it 'accepts pricing rules array' do
      checkout = Checkout.new([])
      expect(checkout.total).to eq('£0.00')
    end
  end

  describe '#total' do
    context 'with no items' do
      it 'returns £0.00' do
        checkout = Checkout.new
        expect(checkout.total).to eq('£0.00')
      end
    end

    context 'with single items' do
      it 'calculates total for one Green Tea' do
        checkout = Checkout.new
        checkout.scan(gr1)
        expect(checkout.total).to eq('£3.11')
      end

      it 'calculates total for one Strawberry' do
        checkout = Checkout.new
        checkout.scan(sr1)
        expect(checkout.total).to eq('£5.00')
      end

      it 'calculates total for one Coffee' do
        checkout = Checkout.new
        checkout.scan(cf1)
        expect(checkout.total).to eq('£11.23')
      end
    end

    context 'with multiple identical items (no pricing rules)' do
      it 'calculates total for multiple Green Teas without discounts' do
        checkout = Checkout.new  # No rules = simple multiplication
        checkout.scan(gr1)
        checkout.scan(gr1)
        expect(checkout.total).to eq('£6.22')  # 2 * 311 = 622p
      end
    end

    context 'with mixed items (no pricing rules)' do
      it 'calculates total for different products without discounts' do
        checkout = Checkout.new  # No rules = simple multiplication
        checkout.scan(gr1)  # 311p
        checkout.scan(sr1)  # 500p
        checkout.scan(cf1)  # 1123p
        expect(checkout.total).to eq('£19.34')  # 1934p total
      end
    end

    context 'with pricing rules integration' do
      let(:pricing_rules) do
        [
          PricingRule::BuyOneGetOneFree.new(product_code: 'GR1'),
          PricingRule::BulkDiscount.new(product_code: 'SR1', min_quantity: 3, discounted_price_in_pence: 450),
          PricingRule::FractionalDiscount.new(product_code: 'CF1', min_quantity: 3, numerator: 2, denominator: 3)
        ]
      end

      # GR1(3): BOGOF = 2*311=622p, SR1(1): regular=500p, CF1(1): regular=1123p Total: 622+500+1123=2245p = £22.45
      it 'calculates Test case 1: GR1,SR1,GR1,GR1,CF1' do
        checkout = Checkout.new(pricing_rules)
        checkout.scan(gr1)
        checkout.scan(sr1)
        checkout.scan(gr1)
        checkout.scan(gr1)
        checkout.scan(cf1)
        expect(checkout.total).to eq('£22.45')
      end

      # GR1(2): BOGOF = 1*311=311p Total: 311p = £3.11
      it 'calculates Test case 2: GR1,GR1' do
        checkout = Checkout.new(pricing_rules)
        checkout.scan(gr1)
        checkout.scan(gr1)
        expect(checkout.total).to eq('£3.11')
      end

      # SR1(3): bulk = 3*450=1350p, GR1(1): regular=311p Total: 1350+311=1661p = £16.61
      it 'calculates Test case 3: SR1,SR1,GR1,SR1' do
        checkout = Checkout.new(pricing_rules)
        checkout.scan(sr1)
        checkout.scan(sr1)
        checkout.scan(gr1)
        checkout.scan(sr1)
        expect(checkout.total).to eq('£16.61')
      end

      # GR1(1): regular=311p, CF1(3): fractional = (3*1123*2/3).round=2246p, SR1(1): regular=500p Total: 311+2246+500=3057p = £30.57
      it 'calculates Test case 4: GR1,CF1,SR1,CF1,CF1' do
        checkout = Checkout.new(pricing_rules)
        checkout.scan(gr1)
        checkout.scan(cf1)
        checkout.scan(sr1)
        checkout.scan(cf1)
        checkout.scan(cf1)
        expect(checkout.total).to eq('£30.57')
      end
    end

    context 'with custom pricing rules' do
      context 'when using different discount rules than standard' do
        let(:custom_rules) do
          [
            PricingRule::BulkDiscount.new(product_code: 'GR1', min_quantity: 5, discounted_price_in_pence: 250),  # Better bulk for 5+ items
            PricingRule::FractionalDiscount.new(product_code: 'SR1', min_quantity: 2, numerator: 1, denominator: 2),  # 50% off for 2+ strawberries
            PricingRule::BuyOneGetOneFree.new(product_code: 'CF1')  # BOGOF for coffee instead of fractional
          ]
        end

        it 'applies custom bulk discount for Green Tea' do
          checkout = Checkout.new(custom_rules)
          5.times { checkout.scan(gr1) }  # 5 Green Teas
          
          # Custom rule: 5 * 250 = 1250p
          expect(checkout.total).to eq('£12.50')
        end

        it 'applies 50% discount for Strawberries' do
          checkout = Checkout.new(custom_rules)
          3.times { checkout.scan(sr1) }  # 3 Strawberries
          
          # Custom fractional: 3 * 500 * 0.5 = 750p
          expect(checkout.total).to eq('£7.50')
        end

        it 'applies BOGOF for Coffee instead of standard fractional' do
          checkout = Checkout.new(custom_rules)
          3.times { checkout.scan(cf1) }  # 3 Coffees
          
          # BOGOF: pay for 2 items = 2 * 1123 = 2246p
          expect(checkout.total).to eq('£22.46')
        end
      end

      context 'best discount selection with competing rules' do
        let(:competing_rules) do
          [
            PricingRule::BuyOneGetOneFree.new(product_code: 'GR1'),  # BOGOF
            PricingRule::BulkDiscount.new(product_code: 'GR1', min_quantity: 3, discounted_price_in_pence: 200),  # Very cheap bulk
            PricingRule::FractionalDiscount.new(product_code: 'GR1', min_quantity: 4, numerator: 1, denominator: 3)  # 33% of original
          ]
        end

        it 'chooses cheapest rule for 4 Green Tea items' do
          checkout = Checkout.new(competing_rules)
          4.times { checkout.scan(gr1) }
          
          # BOGOF: 2 * 311 = 622p
          # Bulk: 4 * 200 = 800p  
          # Fractional: (4 * 311 * 1/3).round = 415p ← cheapest
          expect(checkout.total).to eq('£4.15')
        end

        it 'chooses different best rule for 6 items' do
          checkout = Checkout.new(competing_rules)
          6.times { checkout.scan(gr1) }
          
          # BOGOF: 3 * 311 = 933p
          # Bulk: 6 * 200 = 1200p
          # Fractional: (6 * 311 * 1/3).round = 622p ← cheapest
          expect(checkout.total).to eq('£6.22')
        end
      end

      context 'mixed cart with custom rules' do
        let(:mixed_rules) do
          [
            PricingRule::BulkDiscount.new(product_code: 'GR1', min_quantity: 2, discounted_price_in_pence: 280),
            PricingRule::BuyOneGetOneFree.new(product_code: 'SR1'),
            PricingRule::FractionalDiscount.new(product_code: 'CF1', min_quantity: 2, numerator: 3, denominator: 4)
          ]
        end

        it 'applies best rule for each product type' do
          checkout = Checkout.new(mixed_rules)
          
          # 3 Green Tea with bulk discount
          3.times { checkout.scan(gr1) }  # 3 * 280 = 840p
          
          # 3 Strawberries with BOGOF  
          3.times { checkout.scan(sr1) }  # pay for 2: 2 * 500 = 1000p
          
          # 2 Coffee with fractional
          2.times { checkout.scan(cf1) }  # (2 * 1123 * 3/4).round = 1685p
          
          # Total: 840 + 1000 + 1685 = 3525p = £35.25
          expect(checkout.total).to eq('£35.25')
        end
      end
    end
  end

  context 'validations' do
    let(:checkout) { Checkout.new }

    context 'when scanning invalid items' do
      it 'raises error when item is not a Product' do
        expect { checkout.scan('invalid_item') }
          .to raise_error(ArgumentError, 'Item must be a Product object, got: String')
      end

      it 'raises error when product is not canonical from catalog' do
        fake_product = Product.new(code: 'GR1', name: 'Fake Tea', price_in_pence: 311, currency: 'GBP')
        expect { checkout.scan(fake_product) }
          .to raise_error(ArgumentError, 'Scanned item for code GR1 is not the canonical product from Catalog')
      end
    end

    context 'when scanning valid items' do
      it 'accepts valid canonical products' do
        green_tea = Catalog.find('GR1')
        expect { checkout.scan(green_tea) }.not_to raise_error
      end
    end
  end
end