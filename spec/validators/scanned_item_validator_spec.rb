require_relative '../../lib/product'
require_relative '../../lib/catalog'
require_relative '../../lib/validators/scanned_item_validator'

RSpec.describe ScannedItemValidator do
  describe '#validate!' do
    let(:green_tea) { Catalog.find('GR1') }
    let(:fake_product) { Product.new(code: 'GR1', name: 'Fake Green Tea', price_in_pence: 311, currency: 'GBP') }

    it 'returns the product item when valid canonical product' do
      validator = ScannedItemValidator.new(green_tea)
      expect(validator.validate!).to eq(green_tea)
    end

    it 'raises ArgumentError when item is not a Product object' do
      validator = ScannedItemValidator.new('not_a_product')
      expect { validator.validate! }
        .to raise_error(ArgumentError, 'Item must be a Product object, got: String')
    end

    it 'raises ArgumentError when item is Product but not canonical from Catalog' do
      validator = ScannedItemValidator.new(fake_product)
      expect { validator.validate! }
        .to raise_error(ArgumentError, 'Scanned item for code GR1 is not the canonical product from Catalog')
    end
  end
end