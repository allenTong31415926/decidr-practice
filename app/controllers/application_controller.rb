class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from CsvError::MissingRequiredField, with: :handle_csv_error
  rescue_from StandardError, with: :handle_standard_error

  private

  def handle_csv_error(exception)
    respond_to do |format|
      format.turbo_stream do
        flash.now[:error] = exception.message
        render turbo_stream: turbo_stream.update('flash_messages', partial: 'shared/flash_messages')
      end
      format.html do
        flash[:error] = exception.message
        redirect_to people_path
      end
    end
  end

  def handle_standard_error(exception)
    respond_to do |format|
      format.turbo_stream do
        flash.now[:error] = exception.is_a?(CsvError) ? exception.message : "An error occurred: #{exception.message}"
        render turbo_stream: [
          turbo_stream.update('flash_messages', partial: 'shared/flash_messages'),
          turbo_stream.replace('csv_upload_form', partial: 'people/csv_upload_form')
        ]
      end
      format.html do
        flash[:error] = exception.is_a?(CsvError) ? exception.message : "An error occurred: #{exception.message}"
        redirect_to people_path
      end
    end
  end
end
