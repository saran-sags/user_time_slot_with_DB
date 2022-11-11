class ApplicationController < ActionController::API
    
  class GenericNotFoundError < StandardError; end

  class GenericInvalidInputError < StandardError; end

  unless ENV['DEBUG']
    rescue_from 'StandardError' do |e|
      error_cause = {
        ActionController::UnpermittedParameters => :unprocessable_entity,
        ActionController::ParameterMissing => :unprocessable_entity,
        ApplicationController::GenericNotFoundError => :not_found,
        ApplicationController::GenericInvalidInputError => :unprocessable_entity,
      }[e.exception.class]
      error_cause ||= :internal_server_error
      case error_cause
      when :not_found
        Rails.logger.warn e.message
        msg = obfuscate? ? 'Resource not found' : "#{e.class}: #{e.message}"
        render_status(error_cause, error_hash('base', msg))
      else
        Rails.logger.warn e.message
        Rails.logger.warn "Returning an error with status #{error_cause}"
        render_status(error_cause, error_hash('base', e.message))
      end
    end
  end

  private

  def render_status(status, errors_hash)
    render json: errors_hash, status: status
  end

  def error_hash(key, messages)
    messages = Array(messages) unless messages.is_a?(Array)
    { 'errors' => { key => messages } }
  end
end
