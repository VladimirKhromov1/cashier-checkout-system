# frozen_string_literal: true

require_relative '../support/type_validator'

module DiscountRules
  class Base
    attr_reader :product_code

    def initialize(product_code:)
      @product_code = TypeValidator.validate_string_field!(value: product_code, field_name: 'Product code')
    end

    def applies_to?(product_code:)
      self.product_code == product_code
    end

    def total_amount(original_amount:, quantity:)
      raise NotImplementedError, "The logic must be implemented in the subclasses of DiscountRules::Base"
    end
  end
end
