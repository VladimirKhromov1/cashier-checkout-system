# frozen_string_literal: true

module TypeValidator
  module_function

  def validate_string!(value, field_name)
    raise ArgumentError, "#{field_name} must be a String" unless value.is_a?(String)
    raise ArgumentError, "#{field_name} cannot be empty" if value.strip.empty?
    value
  end

  def validate_positive_integer!(value, field_name)
    raise ArgumentError, "#{field_name} must be an Integer" unless value.is_a?(Integer)
    raise ArgumentError, "#{field_name} must be positive" unless value > 0
    value
  end
end