# frozen_string_literal: true

module TypeValidator
  def self.validate_string_field!(value:, field_name:)
    raise ArgumentError, "#{field_name} must be a String" unless value.is_a?(String)
    raise ArgumentError, "#{field_name} cannot be empty" if value.strip.empty?
    value
  end

  def self.validate_number_field!(value:, field_name:)
    raise ArgumentError, "#{field_name} must be an Integer" unless value.is_a?(Integer)
    raise ArgumentError, "#{field_name} must be positive" unless value > 0
    value
  end
end