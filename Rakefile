require_relative 'lib/checkout'
require_relative 'lib/catalog'
require_relative 'lib/discount_rules/buy_one_get_one_free'
require_relative 'lib/discount_rules/bulk_discount'
require_relative 'lib/discount_rules/fractional_discount'

desc "Verify assignment test cases"
task :verify_assignment do
  puts "Assignment Test Cases:"
  puts "====================="
  
  # Get items from catalog
  green_tea = Catalog.find_product(product_code: 'GR1')
  strawberries = Catalog.find_product(product_code: 'SR1')
  coffee = Catalog.find_product(product_code: 'CF1')
  
  # Discount rules
  discount_rules = [
    DiscountRules::BuyOneGetOneFree.new(product_code: 'GR1'),
    DiscountRules::BulkDiscount.new(product_code: 'SR1', required_quantity: 3, discounted_amount: 450),
    DiscountRules::FractionalDiscount.new(product_code: 'CF1', required_quantity: 3, numerator: 2, denominator: 3)
  ]
  
  # Test Case 1: GR1,SR1,GR1,GR1,CF1 => £22.45
  co = Checkout.new(discount_rules: discount_rules)
  3.times { co.scan(product: green_tea) }
  co.scan(product: strawberries)
  co.scan(product: coffee)
  price = co.total
  puts "Basket: GR1,SR1,GR1,GR1,CF1 => #{price} (expected: £22.45)"
  
  # Test Case 2: GR1,GR1 => £3.11
  co = Checkout.new(discount_rules: discount_rules)
  2.times { co.scan(product: green_tea) }
  price = co.total
  puts "Basket: GR1,GR1 => #{price} (expected: £3.11)"
  
  # Test Case 3: SR1,SR1,GR1,SR1 => £16.61
  co = Checkout.new(discount_rules: discount_rules)
  3.times { co.scan(product: strawberries) }
  co.scan(product: green_tea)
  price = co.total
  puts "Basket: SR1,SR1,GR1,SR1 => #{price} (expected: £16.61)"
  
  # Test Case 4: GR1,CF1,SR1,CF1,CF1 => £30.57
  co = Checkout.new(discount_rules: discount_rules)
  co.scan(product: green_tea)
  3.times { co.scan(product: coffee) }
  co.scan(product: strawberries)
  price = co.total
  puts "Basket: GR1,CF1,SR1,CF1,CF1 => #{price} (expected: £30.57)"
end


