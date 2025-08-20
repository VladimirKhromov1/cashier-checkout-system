require 'spec_helper'

RSpec.describe Catalog do
  describe '.find' do
    it 'finds a product by its code' do
      product = Catalog.find('GR1')

      expect(product).to be_a(Product)
      expect(product.code).to eq('GR1')
      expect(product.name).to eq('Green tea')
      expect(product.price_in_pence).to eq(311)
      expect(product.currency).to eq('GBP')
    end

    it 'returns nil for unknown product code' do
      expect(Catalog.find('UNKNOWN')).to be_nil
    end
  end

  describe '.exists?' do
    it 'returns true for existing product' do
      expect(Catalog.exists?('GR1')).to be true
    end

    it 'returns false for unknown product' do
      expect(Catalog.exists?('UNKNOWN')).to be false
    end
  end
end