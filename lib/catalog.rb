require_relative 'product'

module Catalog
  extend self

  PRODUCTS = {
    'GR1' => Product.new(code: 'GR1', name: 'Green tea', price_in_pence: 311, currency: 'GBP'),
    'SR1' => Product.new(code: 'SR1', name: 'Strawberries', price_in_pence: 500, currency: 'GBP'),
    'CF1' => Product.new(code: 'CF1', name: 'Coffee', price_in_pence: 1123, currency: 'GBP')
  }.freeze

  def find(code)
    PRODUCTS[code]
  end

  def exists?(code)
    PRODUCTS.key?(code)
  end
end