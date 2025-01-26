require "csv"

class CsvImporter
  def self.import(file_path)
    CSV.foreach(file_path, headers: true) do |row|
      # Split 'Name' into first_name and last_name
      name = row["Name"].strip

      # Split the name by the last space
      if name.include?(" ")
        first_name, last_name = name.rpartition(" ")[0..1]
      else
        first_name, last_name = name, nil
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

      # Create or find locations
      locations = location_names.map do |name|
        Location.find_or_create_by(name: name.titlecase)
      end

      # Create or find affiliations
      affiliations = affiliation_names.map do |name|
        Affiliation.find_or_create_by(name: name.titlecase)
      end

      # Create the person and associate relationships
      Person.create(
        first_name: first_name,
        last_name: last_name,
        gender: gender,
        weapon: weapon,
        vehicle: vehicle,
        affiliations: affiliations, # Associate affiliations at creation
        locations: locations
      )
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
