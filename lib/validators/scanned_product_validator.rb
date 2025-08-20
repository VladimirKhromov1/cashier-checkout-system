require_relative '../product'
require_relative '../catalog'

class ScannedProductValidator
  def initialize(product:)
    @product = product
  end

  def validate!
    ensure_is_product_object!
    ensure_is_canonical_product!
    product
  end

  private

  attr_reader :product

  def ensure_is_product_object!
    raise ArgumentError, "Item must be a Product object, got: #{product.class}" unless product.is_a?(Product)
  end

  def ensure_is_canonical_product!
    catalog_product = Catalog.find_product(product_code: product.code)
    raise ArgumentError, "Scanned item for code #{product.code} is not the canonical product from Catalog" unless product.equal?(catalog_product)
  end
end