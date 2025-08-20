require_relative '../lib/checkout'
require_relative '../lib/pricing_rules/buy_one_get_one_free'
require_relative '../lib/pricing_rules/bulk_discount'
require_relative '../lib/pricing_rules/fractional_discount'

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
          PricingRule::BuyOneGetOneFree.new('GR1'),
          PricingRule::BulkDiscount.new('SR1', min_quantity: 3, discounted_price_in_pence: 450),
          PricingRule::FractionalDiscount.new('CF1', min_quantity: 3, numerator: 2, denominator: 3)
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
  end
end