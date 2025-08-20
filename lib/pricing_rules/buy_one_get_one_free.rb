# frozen_string_literal: true

require_relative 'base'

module PricingRule
  class BuyOneGetOneFree < Base
    def initialize(product_code)
      super(product_code)
      freeze
    end

    def total_price_in_pence(product, quantity)
      return 0 if quantity <= 0

      paid_items = (quantity + 1) / 2
      paid_items * product.price_in_pence
    end
  end
end