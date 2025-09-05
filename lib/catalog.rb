# frozen_string_literal: true

require_relative 'product'

module Catalog
  PRODUCTS = {
    'GR1' => Product.new(code: 'GR1', name: 'Green tea', amount: 311, currency: 'GBP'),
    'SR1' => Product.new(code: 'SR1', name: 'Strawberries', amount: 500, currency: 'GBP'),
    'CF1' => Product.new(code: 'CF1', name: 'Coffee', amount: 1123, currency: 'GBP')
  }.freeze

  def self.find_product(product_code:)
    PRODUCTS[product_code]
  end

  def self.find_product!(product_code:)
    product = find_product(product_code: product_code)
    
    unless product
      known_products = PRODUCTS.keys.join(', ')
      raise ArgumentError, "Product with code '#{product_code}' does not exist in the Catalog. Known products: #{known_products}"
    end
    
    product
  end

  def self.product_exists?(product_code:)
    PRODUCTS.key?(product_code)
  end
end