# frozen_string_literal: true

require_relative 'base'

module DiscountRules
  class BuyOneGetOneFree < Base
    def initialize(product_code:)
      super(product_code: product_code)
      freeze
    end

    def total_amount(original_amount:, quantity:)
      return 0 if quantity <= 0

      paid_items = (quantity + 1) / 2
      paid_items * original_amount
    end
  end
end