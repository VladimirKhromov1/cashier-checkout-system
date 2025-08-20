require_relative 'services/scanned_product_amount_calculator'
require_relative 'validators/scanned_product_validator'

class Checkout
  def initialize(discount_rules: [])
    @discount_rules = discount_rules
    @scanned_products = Hash.new(0)
  end

  def scan(product:)
    ScannedProductValidator.new(product: product).validate!
    @scanned_products[product.code] += 1
  end

  def total
    total_amount = calculate_total_amount
    format_currency(total_amount)
  end

  private

  attr_reader :discount_rules, :scanned_products

  def calculate_total_amount
    scanned_products.sum do |product_code, quantity|
      ScannedProductAmountCalculator.new(
        product_code: product_code,
        quantity: quantity,
        rules: discount_rules
      ).call
    end
  end

  def format_currency(amount)
    format('£%.2f', amount / 100.0)
  end
end