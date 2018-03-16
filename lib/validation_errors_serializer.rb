# frozen_string_literal: true

# Validation Errors Serializer
class ValidationErrorsSerializer
  attr_reader :record

  def initialize(record)
    @record = record
  end

  def serialize
    record.errors.messages.map do |field, messages|
      messages.map do |detail|
        ValidationErrorSerializer.new(record, field, detail).serialize
      end
    end.flatten
  end
end
