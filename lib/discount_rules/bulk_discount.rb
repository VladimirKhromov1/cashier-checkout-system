# frozen_string_literal: true

require_relative 'base'
require_relative '../support/type_validator'

module DiscountRules
  class BulkDiscount < Base
    def initialize(product_code:, required_quantity:, discounted_amount:)
      super(product_code: product_code)
      @required_quantity = TypeValidator.validate_number_field!(required_quantity, 'Required quantity')
      @discounted_amount = TypeValidator.validate_number_field!(discounted_amount, 'Discounted amount')
      freeze
    end

    def total_amount(product:, quantity:)
      unit_amount = determine_unit_amount(product: product, quantity: quantity)
      quantity * unit_amount
    end

    private

    attr_reader :required_quantity, :discounted_amount

    def determine_unit_amount(product:, quantity:)
      quantity >= required_quantity ? discounted_amount : product.amount
    end
  end
end