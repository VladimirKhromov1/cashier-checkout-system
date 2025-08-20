# frozen_string_literal: true

require_relative 'base'
require_relative '../support/type_validator'

module PricingRule
  class FractionalDiscount < Base
    def initialize(product_code:, min_quantity:, numerator:, denominator:)
      super(product_code: product_code)
      @min_quantity = TypeValidator.validate_positive_integer!(min_quantity, 'Minimum quantity')
      @ratio = validate_ratio!(numerator, denominator)
      freeze
    end

    def total_price_in_pence(product, quantity)
      return quantity * product.price_in_pence if quantity < min_quantity
      (quantity * product.price_in_pence * ratio).round
    end

    private

    attr_reader :min_quantity, :ratio

    def validate_ratio!(numerator, denominator)
      num = TypeValidator.validate_positive_integer!(numerator, 'Numerator')
      den = TypeValidator.validate_positive_integer!(denominator, 'Denominator')

      unless num < den
        raise ArgumentError, "Numerator (#{num}) must be less than denominator (#{den}) for a discount rule"
      end

      Rational(num, den)
    end
  end
end