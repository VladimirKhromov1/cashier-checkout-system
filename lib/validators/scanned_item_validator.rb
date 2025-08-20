require_relative '../product'
require_relative '../catalog'

class ScannedItemValidator
  def initialize(product_item)
    @product_item = product_item
  end

  def validate!
    ensure_is_product_object!
    ensure_is_canonical_product!
    product_item
  end

  private

  attr_reader :product_item

  def ensure_is_product_object!
    raise ArgumentError, "Item must be a Product object, got: #{product_item.class}" unless product_item.is_a?(Product)
  end

  def ensure_is_canonical_product!
    catalog_product = Catalog.find(product_item.code)
    raise ArgumentError, "Scanned item for code #{product_item.code} is not the canonical product from Catalog" unless product_item.equal?(catalog_product)
  end
end