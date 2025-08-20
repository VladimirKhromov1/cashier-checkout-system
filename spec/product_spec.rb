require_relative '../lib/product'

RSpec.describe Product do
  describe '#initialize' do
    it 'creates a product with basic attributes' do
      product = Product.new(code: 'GR1', name: 'Green Tea', price_in_pence: 311, currency: 'GBP')

      expect(product.code).to eq('GR1')
      expect(product.name).to eq('Green Tea')
      expect(product.price_in_pence).to eq(311)
      expect(product.currency).to eq('GBP')
    end
  end
end