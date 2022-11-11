# frozen_string_literal: true

module Slot  
    # 404
    class NotFound < StandardError; end
  
    # 401
    class Unauthorized < StandardError; end
  
    # 422
    class UnprocessableEntity < StandardError; end
  end
  