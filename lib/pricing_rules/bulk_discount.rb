# frozen_string_literal: true

require_relative '../../lib/pricing_rules/base'

module PricingRule
  class BulkDiscount < Base
    def initialize(product_code, min_quantity:, discounted_price_in_pence:)
      super(product_code)
      @min_quantity = min_quantity
      @discounted_price_in_pence = discounted_price_in_pence
    end

    def total_price_in_pence(product, quantity)
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