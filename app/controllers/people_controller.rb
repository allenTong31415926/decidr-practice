class PeopleController < ApplicationController
  # GET /people
  def index
    @people = Person.includes(:locations, :affiliations).order(:id)

    # Pagination: Limit to 10 results per page
    @page = (params[:page] || 1).to_i
    @people = @people.offset((@page - 1) * 10).limit(10)

    # Search: Filter by first name, last name, or affiliation
    if params[:search].present?
      search_query = params[:search].downcase
      @people = @people.where("LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ?", "%#{search_query}%", "%#{search_query}%")
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
