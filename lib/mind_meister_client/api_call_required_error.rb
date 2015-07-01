module MindMeisterClient
  # Before continuing another call to MM API is required
  class ApiCallRequiredError < Exception
    attr_accessor :msg
    attr_accessor :template
    attr_accessor :api_call_url

    # @param [String] msg
    # @param [String] api_call_url
    def initialize msg, api_call_url
      @msg = msg
      @api_call_url = api_call_url
    end

    def to_s
      setup_template unless @template

      data = {
        api_call_url: @api_call_url,
        msg: @msg
      }

      @template%data
    end

    def setup_template
      @template = '%{msg}: %{api_call_url}'
    end
  end
end
