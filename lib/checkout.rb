require_relative 'catalog'

class Checkout
  def initialize(pricing_rules = [])
    @pricing_rules = pricing_rules
    @scanned_items = Hash.new(0)
  end

  def scan(product)
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
      product.price_in_pence * quantity
    end
  end

  def format_currency(pence)
    format('£%.2f', pence / 100.0)
  end
end