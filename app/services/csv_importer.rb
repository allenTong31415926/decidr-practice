require "csv"

class CsvImporter
  def self.import(file_path)
    ActiveRecord::Base.transaction do
      CSV.foreach(file_path, headers: true).with_index(2) do |row, line_number|
        # Split 'Name' into first_name and last_name
        name = row["Name"]&.strip
        raise CsvError::MissingRequiredField, "CSV Error - Line #{line_number}: Missing Name" if name.blank?

        # Split the name by the last space
        if name.include?(" ")
          last_space_index = name.rindex(" ")
          first_name = name[0...last_space_index]
          last_name = name[last_space_index + 1..]
        else
          first_name = name
        end

        # Extract other fields
        gender = normalize_gender(row["Gender"])
        species = row["Species"]&.strip
        affiliation_names = row["Affiliations"]&.split(",")&.map(&:strip)
        location_names = row["Location"]&.split(",")&.map(&:strip)
        weapon = row["Weapon"]&.strip
        vehicle = row["Vehicle"]&.strip

        # Skip people without affiliations
        next if affiliation_names.blank?

        # Create or find locations and affiliations
        locations = location_names.map do |name|
          Location.find_or_create_by!(name: name.titlecase)
        end

        affiliations = affiliation_names.map do |name|
          Affiliation.find_or_create_by!(name: name.titlecase)
        end

        # Create the person with associations
        Person.create!(
          first_name: first_name,
          last_name: last_name,
          gender: gender,
          weapon: weapon,
          vehicle: vehicle,
          affiliations: affiliations,
          locations: locations
        )
      end
    end
  end

  private
  def self.normalize_gender(value)
    return nil if value.blank?

    case value.to_s.strip.downcase
    when "male", "m"
      "Male"
    when "female", "f"
      "Female"
    when "other"
      "Other"
    else
      nil # Allow nil for blank or unrecognized values
    end
  end
end
