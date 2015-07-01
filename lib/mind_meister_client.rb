require 'json'
require 'mind_meister_client/version'
require 'mind_meister_client/request_error'
require 'mind_meister_client/api_call_required_error'

# Before using this client you need to register your app at https://www.mindmeister.com/api -- API Keys.
# For list of all available methods refer to https://www.mindmeister.com/developers/explore
module MindMeisterClient
  # Handles all request wise stuff
  class Requester
    MM_API_SCOPES   = %w( auth boundaries connections files folders ideas images maps people realtime reflection tasks
                          test themes user)
    SERVER_ADDRESS  = 'www.mindmeister.com'

    # @!attribute api_key
    #   @return [String]
    attr_accessor :api_key
    # @!attribute auth_token
    #   @return [String]
    attr_accessor :auth_token
    # @!attribute http_client
    #   @return [Net::HTTP]
    attr_accessor :http_client

    def initialize api_key, secret_key, auth_token = nil
      @api_key = api_key
      @auth_token = auth_token
      @secret_key = secret_key

      init_http_client
    end

    def init_http_client
      @http_client = Net::HTTP.new SERVER_ADDRESS, 443
      @http_client.use_ssl = true
    end

    # Handles callback call after user of MMC acquired frob
    #
    # @param [String] frob
    #
    # @return [Hash]
    def callback frob
      # Calling MM API to get actual auth_token
      auth_get_token frob: frob
    end

    # When calling MM API method, it is expected to be underscore separated and without the initial mm_
    #
    # @param [Symbol] id Name of method originally called
    def method_missing id, *args
      if api_scope? id
        api_method_name = prepare_api_method id
        request api_method_name, *args
      else
        super
      end
    end

    # Detects if method name seems to be from MM API
    #
    # @param [Symbol] ruby_method_name
    #
    # @return [TrueClass]
    def api_scope? ruby_method_name
      ruby_method_scope = ruby_method_name.to_s.split('_')[0]

      ruby_method_scope && MM_API_SCOPES.include?(ruby_method_scope)
    end


    # Makes the actual call to MM API
    #
    # @raise [MindMeisterClient::ApiCallRequiredError] When no auth_token has been set up
    # @raise [MindMeisterClient::RequestError] When MM API returns an error
    #
    # @param [String] api_method_name
    #
    # @return [Hash]
    def request api_method_name, *args
      unless @auth_token || api_method_name =~ /auth/
        raise_auth_token_request
      end

      if args[0]
        api_call_params = args[0].merge(api_default_params)
      else
        api_call_params = api_default_params
      end

      api_call_params[:method] = api_method_name

      api_data = JSON.parse http_client.get('/services/rest?' + signed_query_string(api_call_params)).body,
                            symbolize_names: true

      if api_data[:rsp][:stat] == 'fail'
        raise RequestError.new api_data[:rsp][:err][:code].to_i,
                               api_data[:rsp][:err][:msg],
                               api_call_params
      else
        api_data[:rsp]
      end

    end

    # @raise [ApiCallRequiredError] Every day'n'night!
    def raise_auth_token_request
      api_call_params = {
        api_key:  @api_key,
        method:   'mm.auth.getToken',
        perms:    'read'
      }
      raise ApiCallRequiredError.new 'Authentication token missing',
                                     'https://%s/services/auth/?%s'%[
                                       SERVER_ADDRESS,
                                       signed_query_string(api_call_params)
                                     ]
    end

    # Bare minimum to send to MM API
    #
    # @return [Hash]
    def api_default_params
      { api_key: @api_key,
        auth_token: @auth_token,
        response_format: 'json'
      }
    end

    # maps_new_from_template -> mm.maps.newFromTemplate
    #
    # This is helper for method_missing method of this class
    #
    # @param [Symbol] ruby_method_name
    #
    # @return [String]
    def prepare_api_method ruby_method_name
      rmn_parts = ruby_method_name.to_s.split('_')

      'mm.%s.%s%s'%[
        rmn_parts[0],
        rmn_parts[1],
        rmn_parts[2..rmn_parts.length].map(&:capitalize).join('')
      ]

    end

    # From hash, this methods creates query parameters for API call. This method also appends signature, required by
    #   most of MindMeister API calls.
    #
    # More about signing MM API calls at https://www.mindmeister.com/developers/authentication
    #
    # @param [Hash] params
    #
    # @return [String]
    def signed_query_string params
      query_params_joined = params.sort.inject('') { |memo, key|
        memo += key[0].to_s + key[1].to_s
        memo
      }

      signature_data = @secret_key + query_params_joined

      query_string_params = URI.encode_www_form(params)

      signature = Digest::MD5.hexdigest(signature_data)

      query_string_params + '&api_sig=' + signature
    end

    # @!group MindMeister API methods

    #
    # List of virtual methods from MM API
    #   Taken from https://www.mindmeister.com/developers/explore
    #

    #
    # auth
    #

    # @!method auth_check_token
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method auth_get_frob
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method auth_get_token
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    #
    # boundaries
    #

    # @!method boundaries_add
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method boundaries_change
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method boundaries_delete
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    #
    # connections
    #

    # @!method connections_add
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method connections_change_color
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method connections_change_control_points
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method connections_change_label
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method connections_delete
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    #
    # files
    #

    # @!method files_add
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    #
    # folders
    #

    # @!method folders_add
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method folders_contents
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method folders_delete
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method folders_get_list
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method folders_move
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method folders_rename
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    #
    # ideas
    #

    # @!method ideas_add_attachment
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method ideas_change
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method ideas_delete
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method ideas_delete_attachment
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method ideas_get_map
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method ideas_insert
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method ideas_move
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method ideas_remove_style
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method ideas_set_style
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method ideas_toggle_closed
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    #
    # images
    #

    # @!method images_add
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method images_delete
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method images_upload
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    #
    # maps
    #

    # @!method maps_add
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_delete
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_duplicate
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_export
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_get_channel
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_get_collaborators
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_get_list
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_get_map
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_get_notification
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_get_public_list
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_get_public_map
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_get_slides
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_get_templates
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_history
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_import
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_insert_geistesblitz
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_link_share
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_move
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_new_from_template
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_publish
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_redo
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_remove_link_share
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_revert
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_set_meta_data
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_set_notification
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_set_properties
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_set_theme
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_share
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_un_publish
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_un_share
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_undo
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method maps_withdraw
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    #
    # people
    #

    # @!method people_get_friends
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method people_get_info
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    #
    # realtime
    #

    # @!method realtime_do
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method realtime_poll
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    #
    # reflection
    #

    # @!method reflection_api_version
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method reflection_get_method_info
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method reflection_get_methods
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    #
    # tasks
    #

    # @!method tasks_add
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method tasks_delete
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method tasks_set_notification
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    #
    # test
    #

    # @!method test_echo Dum dum dummy
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method test_login
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method test_null
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    #
    # themes
    #

    # @!method themes_default_list
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method themes_templates
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    #
    # user
    #

    # @!method user_browser_login
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method user_external_login
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method user_get_groups
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method user_get_styles
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method user_get_team_themes
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method user_mobile_login
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!method user_mobile_signup
    #   @param [Hash] params
    #
    #   @return [Hash] Data from MM API

    # @!endgroup
  end
end
