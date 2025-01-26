class PeopleController < ApplicationController
  # GET /people
  def index
    @people = Person.includes(:locations, :affiliations).order(:id)

    # Pagination: Limit to 10 results per page
    @page = (params[:page] || 1).to_i
    @people = @people.offset((@page - 1) * 10).limit(10)

    # Search: Filter by multiple fields including associations
    if params[:search].present?
      search_query = params[:search].downcase
      @people = @people.joins(:locations, :affiliations).where(
        "LOWER(people.first_name) LIKE :query OR
         LOWER(people.last_name) LIKE :query OR
         LOWER(people.weapon) LIKE :query OR
         LOWER(people.vehicle) LIKE :query OR
         LOWER(locations.name) LIKE :query OR
         LOWER(affiliations.name) LIKE :query OR
         CASE people.gender
           WHEN 0 THEN 'male'
           WHEN 1 THEN 'female'
           WHEN 2 THEN 'other'
         END = :exact_query",
        query: "%#{search_query}%",
        exact_query: search_query
      ).distinct
    end

    # Sorting: Order by column if provided (default is ID)
    if params[:sort].present? && Person.column_names.include?(params[:sort])
      @people = @people.order("#{params[:sort]} ASC")
    end
  end

  # POST /people/csv_upload
  def csv_upload
    file = params[:file]
    if file.present?
      begin
        CsvImporter.import(file.path)
        flash[:notice] = "CSV imported successfully."
      rescue => e
        flash[:alert] = "Error during CSV import: #{e.message}"
      end
    else
      flash[:alert] = "No file was provided."
    end

    redirect_to people_path
  end
end
