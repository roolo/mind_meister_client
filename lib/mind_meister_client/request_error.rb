module MindMeisterClient
  # Error occurred during request call
  class RequestError < Exception
    # Object not found
    MM_ERROR_OBJECT_NOT_FOUND = 20
    # Well...
    MM_ERROR_REQUIRED_PARAMETER_MISSING = 23
    # The passed signature was invalid.
    MM_ERROR_INVALID_SIGNATURE = 96
    # The call required signing but no signature was sent.
    MM_ERROR_MISSING_SIGNATURE = 97
    # The login details or auth token passed were invalid.
    MM_ERROR_LOGIN_FAILED = 98
    # The API key passed was not valid or has expired.
    MM_ERROR_INVALID_API_KEY = 100
    # The specified frob does not exist or has already been used.
    MM_ERROR_INVALID_FROB = 108
    # The requested method was not found.
    MM_ERROR_METHOD_NOT_FOUND = 112

    attr_accessor :code
    attr_accessor :msg
    attr_accessor :provided_data
    attr_accessor :template

    # @param [String] code
    # @param [String] msg
    # @param [Hash] provided_data
    def initialize code, msg, provided_data
      @code = code
      @msg = msg
      @provided_data = provided_data
    end

    def to_s
      setup_template unless @template

      data = @provided_data.dup
      data[:code] = @code
      data[:msg] = @msg

      @template%data
    end

    def setup_template
      @template = '%{code}: %{method} -- %{msg}'
      case @code.to_i
        when MM_ERROR_METHOD_NOT_FOUND
          @template += ' (method name between >s: >%{method}<)'
        when MM_ERROR_REQUIRED_PARAMETER_MISSING
          @template += @provided_data.inspect
        when MM_ERROR_INVALID_FROB
          @template += ' (provided frob between >s: >%{frob}<)'
        else
      end
    end
  end
end
