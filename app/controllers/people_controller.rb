class PeopleController < ApplicationController
  RESULTS_PER_PAGE = 10

  # Displays the index page with paginated and optionally filtered people
  # @return [void]
  def index
    @page = (params[:page] || 1).to_i
    @people = find_people
  end

  # Handles CSV file upload and imports data
  # @return [void]
  # @raise [CsvError::MissingRequiredField] if required fields are missing in CSV
  def csv_upload
    CsvImporter.import(params[:file].path)
    flash[:notice] = "CSV Success - All records imported"

    redirect_to people_path
  end

  private

  # Retrieves people with associations and optional search filtering
  # @return [ActiveRecord::Relation<Person>] collection of people
  def find_people
    people = Person.includes(:locations, :affiliations).
                    joins(:locations, :affiliations).
                    order(:id)

    people = apply_search(people) if params[:search].present?
    apply_pagination(people)
  end

  # Applies search filtering to the query
  # @param scope [ActiveRecord::Relation<Person>] the current query scope
  # @return [ActiveRecord::Relation<Person>] filtered query scope
  def apply_search(scope)
    search_query = params[:search].downcase
    scope.where(search_conditions, search_params(search_query)).distinct
  end

  # Defines SQL conditions for searching across multiple fields
  # @return [String] SQL WHERE clause conditions
  def search_conditions
    <<-SQL
      LOWER(people.first_name) LIKE :query OR
      LOWER(people.last_name) LIKE :query OR
      LOWER(people.weapon) LIKE :query OR
      LOWER(people.vehicle) LIKE :query OR
      LOWER(locations.name) LIKE :query OR
      LOWER(affiliations.name) LIKE :query OR
      CASE people.gender
        WHEN 0 THEN 'male'
        WHEN 1 THEN 'female'
        WHEN 2 THEN 'other'
      END = :exact_query
    SQL
  end

  # Generates search parameters for the query
  # @param query [String] the search term
  # @return [Hash] hash of query parameters
  def search_params(query)
    {
      query: "%#{query}%",
      exact_query: query
    }
  end

  # Applies pagination to the query
  # @param scope [ActiveRecord::Relation<Person>] the current query scope
  # @return [ActiveRecord::Relation<Person>] paginated query scope
  def apply_pagination(scope)
    scope.offset((@page - 1) * RESULTS_PER_PAGE).limit(RESULTS_PER_PAGE)
  end
end
