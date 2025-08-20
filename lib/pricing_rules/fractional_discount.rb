# frozen_string_literal: true

require_relative 'base'

module PricingRule
  class FractionalDiscount < Base
    def initialize(product_code, min_quantity:, numerator:, denominator:)
      super(product_code)
      @min_quantity = min_quantity
      @ratio = Rational(numerator, denominator)
    end

    def total_price_in_pence(product, quantity)
      return quantity * product.price_in_pence if quantity < min_quantity
      (quantity * product.price_in_pence * ratio).round
    end

    private

    attr_reader :min_quantity, :ratio
  end
end