require_relative '../lib/checkout'

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

    context 'with multiple identical items' do
      it 'calculates total for multiple Green Teas' do
        checkout = Checkout.new
        checkout.scan(gr1)
        checkout.scan(gr1)
        expect(checkout.total).to eq('£6.22')
      end
    end

    context 'with mixed items' do
      it 'calculates total for different products' do
        checkout = Checkout.new
        checkout.scan(gr1)
        checkout.scan(sr1)
        checkout.scan(cf1)
        expect(checkout.total).to eq('£19.34')
      end
    end
  end
end