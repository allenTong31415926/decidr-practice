require "csv"

class CsvImporter
  def self.import(file_path)
    new(file_path).import
  end

  def initialize(file_path)
    @file_path = file_path
  end

  def import
    ActiveRecord::Base.transaction do
      CSV.foreach(@file_path, headers: true).with_index(2) do |row, line_number|
        process_row(row, line_number)
      end
    end
  end

  private

  def process_row(row, line_number)
    parsed_data = ParsedRowData.new(row, line_number)
    return if parsed_data.affiliations.blank?

    create_person(parsed_data)
  end

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

  def find_or_create_locations(names)
    names.map { |name| Location.find_or_create_by!(name: name.titlecase) }
  end

  def find_or_create_affiliations(names)
    names.map { |name| Affiliation.find_or_create_by!(name: name.titlecase) }
  end

  class ParsedRowData
    attr_reader :first_name, :last_name, :gender, :weapon, :vehicle, :affiliations, :locations

    def initialize(row, line_number)
      parse_name(row["Name"], line_number)
      @gender = CsvImporter.normalize_gender(row["Gender"])
      @weapon = row["Weapon"]&.strip
      @vehicle = row["Vehicle"]&.strip
      @affiliations = row["Affiliations"]&.split(",")&.map(&:strip)
      @locations = row["Location"]&.split(",")&.map(&:strip) || []
    end

    private

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

  def self.normalize_gender(value)
    return nil if value.blank?

    case value.to_s.strip.downcase
    when "male", "m" then "Male"
    when "female", "f" then "Female"
    when "other" then "Other"
    end
  end
end
