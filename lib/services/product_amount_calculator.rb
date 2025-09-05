# frozen_string_literal: true

require_relative '../catalog'

class ProductAmountCalculator
  def initialize(product_code:, quantity:, rules:)
    @product_code = product_code
    @quantity = quantity
    @rules = rules
  end

  def call
    best_rule = find_most_beneficial_rule

    if best_rule
      best_rule.total_amount(original_amount: product.amount, quantity: quantity)
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
    applicable_rules = rules.select { |rule| rule.applies_to?(product_code: product.code) }
    return nil if applicable_rules.empty?

    applicable_rules.min_by do |rule|
      rule.total_amount(original_amount: product.amount, quantity: quantity)
    end
  end
end
