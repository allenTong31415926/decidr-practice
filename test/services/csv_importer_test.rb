require "test_helper"

class CsvImporterTest < ActiveSupport::TestCase
  setup do
    @affiliation = Affiliation.create!(name: "Test Affiliation")
    @location = Location.create!(name: "Test Location")
  end

  test "imports valid CSV data" do
    file = file_fixture("valid_people.csv")
    
    assert_difference "Person.count" do
      CsvImporter.import(file)
    end

    person = Person.last
    assert_equal "Luke", person.first_name
    assert_equal "Skywalker", person.last_name
    assert_equal "Male", person.gender
    assert_equal "Lightsaber", person.weapon
    assert_equal "X-wing", person.vehicle
    assert_includes person.affiliations.map(&:name), "Rebel Alliance"
    assert_includes person.locations.map(&:name), "Tatooine"
  end

  test "raises error when name is missing" do
    file = file_fixture("invalid_people.csv")
    
    error = assert_raises(CsvError::MissingRequiredField) do
      CsvImporter.import(file)
    end

    assert_match /CSV Error - Line 2: Missing Name/, error.message
    assert_no_difference "Person.count" do
      assert_raises(CsvError::MissingRequiredField) do
        CsvImporter.import(file)
      end
    end
  end

  test "skips records without affiliations" do
    file = file_fixture("no_affiliation.csv")
    
    assert_no_difference "Person.count" do
      CsvImporter.import(file)
    end
  end

  test "normalizes gender values" do
    file = file_fixture("gender_variants.csv")
    
    CsvImporter.import(file)
    
    people = Person.last(3)
    assert_equal "Male", people[0].gender    # From "m"
    assert_equal "Female", people[1].gender  # From "f"
    assert_nil people[2].gender             # From "unknown"
  end
end 