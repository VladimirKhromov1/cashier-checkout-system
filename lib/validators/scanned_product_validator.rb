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

    unless catalog_product
      raise ArgumentError, "Product with code '#{product.code}' does not exist in the Catalog"
    end

    unless product.equal?(catalog_product)
      raise ArgumentError, "Scanned item for code #{product.code} is not the canonical product from Catalog"
    end
  end
end