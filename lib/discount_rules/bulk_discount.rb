# frozen_string_literal: true

require_relative 'base'
require_relative '../support/type_validator'

module DiscountRules
  class BulkDiscount < Base
    def initialize(product_code:, required_quantity:, discounted_amount:)
      super(product_code: product_code)
      @required_quantity = TypeValidator.validate_number_field!(value: required_quantity, field_name: 'Required quantity')
      @discounted_amount = TypeValidator.validate_number_field!(value: discounted_amount, field_name: 'Discounted amount')
      freeze
    end

    def total_amount(original_amount:, quantity:)
      unit_amount = determine_unit_amount(original_amount, quantity)
      quantity * unit_amount
    end

    private

    attr_reader :required_quantity, :discounted_amount

    def determine_unit_amount(original_amount, quantity)
      quantity >= required_quantity ? discounted_amount : original_amount
    end
  end
end
