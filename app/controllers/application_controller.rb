require 'rollbar'

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from CsvError::MissingRequiredField, with: :handle_csv_error
  rescue_from StandardError, with: :handle_standard_error

  private

  # Handles CSV-specific errors with appropriate response
  # @param exception [CsvError::MissingRequiredField] the caught exception
  # @return [void]
  def handle_csv_error(exception)
    flash.now[:error] = exception.message

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.update('flash_messages', partial: 'shared/flash_messages') }
      format.html { redirect_to people_path }
    end
  end

  # Handles general errors with logging and appropriate response
  # @param exception [StandardError] the caught exception
  # @return [void]
  def handle_standard_error(exception)
    Rollbar.error(exception,
      controller: controller_name,
      action: action_name,
      params: request.filtered_parameters
    )

    flash.now[:error] = exception.message

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.update('flash_messages', partial: 'shared/flash_messages') }
      format.html { redirect_to people_path }
    end
  end
end
