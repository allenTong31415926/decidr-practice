require "csv"

class CsvImporter
  # Imports data from a CSV file and creates Person records
  # @param file_path [String] path to the CSV file
  # @return [void]
  def self.import(file_path)
    new(file_path).import
  end

  # Initialize a new CsvImporter instance
  # @param file_path [String] path to the CSV file
  def initialize(file_path)
    @file_path = file_path
  end

  # Process the CSV file and import records within a transaction
  # @return [void]
  # @raise [CsvError::MissingRequiredField] if required fields are missing
  def import
    ActiveRecord::Base.transaction do
      CSV.foreach(@file_path, headers: true).with_index(2) do |row, line_number|
        process_row(row, line_number)
      end
    end
  end

  private

  # Process a single row from the CSV
  # @param row [CSV::Row] the row to process
  # @param line_number [Integer] the current line number in the CSV
  # @return [void]
  def process_row(row, line_number)
    parsed_data = ParsedRowData.new(row, line_number)
    return if parsed_data.affiliations.blank?

    create_person(parsed_data)
  end

  # Create a new Person record from parsed data
  # @param data [ParsedRowData] the parsed row data
  # @return [Person] the created person record
  def create_person(data)
    Person.create!(
      first_name: data.first_name,
      last_name: data.last_name,
      gender: data.gender,
      weapon: data.weapon,
      vehicle: data.vehicle,
      affiliations: find_or_create_affiliations(data.affiliations),
      locations: find_or_create_locations(data.locations)
    )
  end

  # Find or create Location records
  # @param names [Array<String>] array of location names
  # @return [Array<Location>] array of Location records
  def find_or_create_locations(names)
    names.map { |name| Location.find_or_create_by!(name: name.titlecase) }
  end

  # Find or create Affiliation records
  # @param names [Array<String>] array of affiliation names
  # @return [Array<Affiliation>] array of Affiliation records
  def find_or_create_affiliations(names)
    names.map { |name| Affiliation.find_or_create_by!(name: name.titlecase) }
  end

  # Normalize gender values from CSV
  # @param value [String, nil] the gender value from CSV
  # @return [String, nil] normalized gender value or nil if invalid
  def self.normalize_gender(value)
    return nil if value.blank?

    case value.to_s.strip.downcase
    when "male", "m" then "Male"
    when "female", "f" then "Female"
    when "other" then "Other"
    end
  end

  # Class to parse and validate CSV row data
  class ParsedRowData
    attr_reader :first_name, :last_name, :gender, :weapon, :vehicle, :affiliations, :locations

    # Initialize parsed row data
    # @param row [CSV::Row] the CSV row to parse
    # @param line_number [Integer] current line number in CSV
    # @raise [CsvError::MissingRequiredField] if name is missing
    def initialize(row, line_number)
      parse_name(row["Name"], line_number)
      @gender = CsvImporter.normalize_gender(row["Gender"])
      @weapon = row["Weapon"]&.strip
      @vehicle = row["Vehicle"]&.strip
      @affiliations = row["Affiliations"]&.split(",")&.map(&:strip)
      @locations = row["Location"]&.split(",")&.map(&:strip) || []
    end

    private

    # Parse full name into first and last name
    # @param name [String, nil] full name from CSV
    # @param line_number [Integer] current line number in CSV
    # @raise [CsvError::MissingRequiredField] if name is missing
    def parse_name(name, line_number)
      raise CsvError::MissingRequiredField, "CSV Error - Line #{line_number}: Missing Name" if name.blank?

      if name.include?(" ")
        last_space_index = name.rindex(" ")
        @first_name = name[0...last_space_index]
        @last_name = name[last_space_index + 1..]
      else
        @first_name = name
        @last_name = nil
      end
    end
  end
end
