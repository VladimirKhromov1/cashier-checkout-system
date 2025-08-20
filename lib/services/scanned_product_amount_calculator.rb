require_relative '../catalog'

class ScannedProductAmountCalculator
  def initialize(product_code:, quantity:, rules:)
    @product_code = product_code
    @quantity = quantity
    @rules = rules
  end

  def call
    best_rule = find_most_beneficial_rule

    if best_rule
      best_rule.total_amount(product: product, quantity: quantity)
    else
      product.amount * quantity
    end
  end

  private

  attr_reader :product_code, :quantity, :rules

  def product
    Catalog.find_product(product_code: product_code)
  end

  def find_most_beneficial_rule
    applicable_rules = rules.select { |rule| rule.applies_to?(product: product) }
    return nil if applicable_rules.empty?

    applicable_rules.min_by do |rule|
      rule.total_amount(product: product, quantity: quantity)
    end
  end
end