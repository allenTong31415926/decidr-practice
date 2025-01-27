require "test_helper"

class PeopleControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Create test data
    @location = Location.create!(name: "Test Location")
    @affiliation = Affiliation.create!(name: "Test Affiliation")
    @person = Person.create!(
      first_name: "John",
      last_name: "Doe",
      gender: "Male",
      weapon: "Lightsaber",
      vehicle: "X-wing",
      locations: [@location],
      affiliations: [@affiliation]
    )
  end

  test "should get index" do
    get people_path
    assert_response :success
    assert_not_nil assigns(:people)
  end

  test "should search people" do
    get people_path, params: { search: "lightsaber" }
    assert_response :success
    assert_equal [@person], assigns(:people)
  end

  test "should handle pagination" do
    get people_path, params: { page: 2 }
    assert_response :success
    assert_equal 2, assigns(:page)
  end

  test "should upload valid CSV" do
    file = fixture_file_upload('valid_people.csv', 'text/csv')
    assert_difference('Person.count') do
      post csv_upload_people_path, params: { file: file }
    end
    assert_redirected_to people_path
    assert_equal "CSV Success - All records imported", flash[:notice]
  end

  test "should handle missing name in CSV" do
    file = fixture_file_upload('invalid_people.csv', 'text/csv')
    assert_no_difference('Person.count') do
      post csv_upload_people_path, params: { file: file }, headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end
    assert_response :success
    assert_match /CSV Error - Line 2: Missing Name/, flash[:error]
  end
end
