class PeopleController < ApplicationController
  RESULTS_PER_PAGE = 10

  # GET /people
  def index
    @page = (params[:page] || 1).to_i
    @people = find_people
  end

  # POST /people/csv_upload
  def csv_upload
    CsvImporter.import(params[:file].path)
    flash[:notice] = "CSV Success - All records imported"

    redirect_to people_path
  end

  private

  def find_people
    people = Person.includes(:locations, :affiliations).
                    joins(:locations, :affiliations).
                    order(:id)

    people = apply_search(people) if params[:search].present?
    apply_pagination(people)
  end

  def apply_search(scope)
    search_query = params[:search].downcase
    scope.where(search_conditions, search_params(search_query)).distinct
  end

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

  def search_params(query)
    {
      query: "%#{query}%",
      exact_query: query
    }
  end

  def apply_pagination(scope)
    scope.offset((@page - 1) * RESULTS_PER_PAGE).limit(RESULTS_PER_PAGE)
  end
end
