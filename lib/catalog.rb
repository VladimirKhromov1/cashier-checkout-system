require_relative 'product'

module Catalog
  PRODUCTS = {
    'GR1' => Product.new(code: 'GR1', name: 'Green tea', amount: 311, currency: 'GBP'),
    'SR1' => Product.new(code: 'SR1', name: 'Strawberries', amount: 500, currency: 'GBP'),
    'CF1' => Product.new(code: 'CF1', name: 'Coffee', amount: 1123, currency: 'GBP')
  }.freeze

  def find_product(product_code:)
    PRODUCTS[product_code]
  end

  def product_exists?(product_code:)
    PRODUCTS.key?(product_code)
  end

  module_function :find_product, :product_exists?
end