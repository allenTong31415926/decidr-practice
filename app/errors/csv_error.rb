# CSV-specific errors
class CsvError < ApplicationError
  class MissingRequiredField < CsvError; end
end 