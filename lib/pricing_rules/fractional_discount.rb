# frozen_string_literal: true

require_relative '../../lib/pricing_rules/base'

module PricingRule
  class FractionalDiscount < Base
    def initialize(product_code, min_quantity:, numerator:, denominator:)
      super(product_code)
      @min_quantity = min_quantity
      @ratio = Rational(numerator, denominator)
    end

    def total_price_in_pence(product, quantity)
      unit_price = determine_unit_price(product, quantity)
      quantity * unit_price
    end

    private

    attr_reader :min_quantity, :ratio

    def determine_unit_price(product, quantity)
      return product.price_in_pence if quantity < min_quantity
      (product.price_in_pence * ratio).round
    end
  end
end