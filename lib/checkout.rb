require_relative 'catalog'
require_relative 'validators/scanned_item_validator'

class Checkout
  def initialize(pricing_rules = [])
    @pricing_rules = pricing_rules
    @scanned_items = Hash.new(0)
  end

  def scan(product)
    ScannedItemValidator.new(product).validate!
    @scanned_items[product.code] += 1
  end

  def total
    total_pence = calculate_total_pence
    format_currency(total_pence)
  end

  private

  attr_reader :pricing_rules, :scanned_items

  def calculate_total_pence
    scanned_items.sum do |code, quantity|
      product = Catalog.find(code)

      applicable_rule = pricing_rules.find { |rule| rule.applies_to?(product) }

      if applicable_rule
        applicable_rule.total_price_in_pence(product, quantity)
      else
        product.price_in_pence * quantity
      end
    end
  end

  def format_currency(pence)
    format('£%.2f', pence / 100.0)
  end
end