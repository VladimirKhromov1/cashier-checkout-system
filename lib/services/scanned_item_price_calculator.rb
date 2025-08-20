require_relative '../catalog'

class ScannedItemPriceCalculator
  def initialize(product_code:, quantity:, rules:)
    @product_code = product_code
    @quantity = quantity
    @rules = rules
  end

  def call
    applicable_rule = find_applicable_rule

    if applicable_rule
      applicable_rule.total_price_in_pence(product, quantity)
    else
      product.price_in_pence * quantity
    end
  end

  private

  attr_reader :product_code, :quantity, :rules

  def product
    Catalog.find(product_code)
  end

  def find_applicable_rule
    rules.find { |rule| rule.applies_to?(product) }
  end
end