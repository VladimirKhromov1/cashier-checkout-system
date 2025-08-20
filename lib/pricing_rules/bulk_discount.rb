# frozen_string_literal: true

require_relative 'base'
require_relative '../support/type_validator'

module PricingRule
  class BulkDiscount < Base
    def initialize(product_code:, min_quantity:, discounted_price_in_pence:)
      super(product_code: product_code)
      @min_quantity = TypeValidator.validate_number_field!(min_quantity, 'Minimum quantity')
      @discounted_price_in_pence = TypeValidator.validate_number_field!(discounted_price_in_pence, 'Discounted price')
      freeze
    end

    def total_price(product, quantity)
      unit_price = determine_unit_price(product, quantity)
      quantity * unit_price
    end

    private

    attr_reader :min_quantity, :discounted_price_in_pence

    def determine_unit_price(product, quantity)
      quantity >= min_quantity ? discounted_price_in_pence : product.price_in_pence
    end
  end
end