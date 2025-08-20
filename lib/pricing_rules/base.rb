# frozen_string_literal: true

require_relative '../support/type_validator'
require_relative '../catalog'

module PricingRule
  class Base
    attr_reader :product_code

    def initialize(product_code)
      @product_code = validate_code!(product_code)
    end

    def applies_to?(product)
      product.code == product_code
    end

    def total_price_in_pence(_product, _quantity)
      raise NotImplementedError, "The logic must be implemented in the subclasses of PricingRule::Base"
    end

    private

    def validate_code!(code)
      c = TypeValidator.validate_string!(code, 'Product code for rule')
      unless Catalog.exists?(c)
        known_products = Catalog::PRODUCTS.keys.join(', ')
        raise ArgumentError, "Rule cannot be created for unknown product: '#{c}'. Known products: #{known_products}"
      end
      c
    end
  end
end