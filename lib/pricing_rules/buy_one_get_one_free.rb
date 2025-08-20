# frozen_string_literal: true

require_relative '../../lib/pricing_rules/base'

module PricingRule
  class BuyOneGetOneFree < Base
    def total_price_in_pence(product, quantity)
      return 0 if quantity <= 0

      paid_items = (quantity + 1) / 2
      paid_items * product.price_in_pence
    end
  end
end