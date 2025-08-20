# frozen_string_literal: true

require_relative 'base'
require_relative '../support/type_validator'

module DiscountRules
  class FractionalDiscount < Base
    def initialize(product_code:, required_quantity:, numerator:, denominator:)
      super(product_code: product_code)
      @required_quantity = TypeValidator.validate_number_field!(required_quantity, 'Required quantity')
      @ratio = validate_ratio!(numerator, denominator)
      freeze
    end

    def total_amount(product:, quantity:)
      return quantity * product.amount if quantity < required_quantity
      (quantity * product.amount * ratio).round
    end

    private

    attr_reader :required_quantity, :ratio

    def validate_ratio!(numerator, denominator)
      num = TypeValidator.validate_number_field!(numerator, 'Numerator')
      den = TypeValidator.validate_number_field!(denominator, 'Denominator')

      unless num < den
        raise ArgumentError, "Numerator (#{num}) must be less than denominator (#{den}) for a discount rule"
      end

      Rational(num, den)
    end
  end
end