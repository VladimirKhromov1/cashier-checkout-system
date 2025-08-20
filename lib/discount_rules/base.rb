# frozen_string_literal: true

require_relative '../support/type_validator'
require_relative '../catalog'

module DiscountRules
  class Base
    attr_reader :product_code

    def initialize(product_code:)
      @product_code = validate_code!(product_code)
    end

    def applies_to?(product:)
      product.code == product_code
    end

    def total_amount(product:, quantity:)
      raise NotImplementedError, "The logic must be implemented in the subclasses of DiscountRules::Base"
    end

    private

    def validate_code!(product_code)
      c = TypeValidator.validate_string_field!(value: product_code, field_name: 'Product code for rule')
      unless Catalog.product_exists?(product_code: c)
        known_products = Catalog::PRODUCTS.keys.join(', ')
        raise ArgumentError, "Rule cannot be created for unknown product: '#{c}'. Known products: #{known_products}"
      end
      c
    end
  end
end