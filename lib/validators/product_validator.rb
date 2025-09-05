# frozen_string_literal: true

require_relative '../product'
require_relative '../catalog'

class ProductValidator
  def initialize(product:)
    @product = product
  end

  def validate!
    ensure_matches_catalog!
  end

  private

  attr_reader :product

  def ensure_matches_catalog!
    catalog_product = Catalog.find_product!(product_code: product.code)
    ensure_attributes_match!(catalog_product)
  rescue NoMethodError
    raise ArgumentError, "Item must be a Product object, got: #{product.class}"
  end

  def ensure_attributes_match!(catalog_product)
    unless catalog_product.matches?(product: product)
      raise ArgumentError, "Scanned item for code #{product.code} does not match canonical product from Catalog"
    end
  end
end
