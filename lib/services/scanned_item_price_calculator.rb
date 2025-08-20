require_relative '../catalog'

class ScannedItemPriceCalculator
  def initialize(product_code:, quantity:, rules:)
    @product_code = product_code
    @quantity = quantity
    @rules = rules
  end

  def call
    best_rule = find_most_beneficial_rule

    if best_rule
      best_rule.total_price(product, quantity)
    else
      product.price_in_pence * quantity
    end
  end

  private

  attr_reader :product_code, :quantity, :rules

  def product
    Catalog.find(product_code)
  end

  def find_most_beneficial_rule
    applicable_rules = rules.select { |rule| rule.applies_to?(product) }
    return nil if applicable_rules.empty?

    applicable_rules.min_by do |rule|
      rule.total_price(product, quantity)
    end
  end
end