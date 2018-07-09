require 'ostruct'

class RequestRideDetails
  GO_RIDE_HOST = 'go-ride-details'.freeze

  attr_reader :from, :to

  def initialize(from:, to:)
    @from = from
    @to = to
  end

  def call
    httpResponse = fetch_data # async request

    if httpResponse.error
      return error_response("Got unexpected error from go-ride-details: '#{httpResponse.error}'")
    end

    begin
      parsedResponse = JSON.parse(httpResponse.response)
    rescue JSON::ParserError
      return error_response("Error parsing go-ride-details response: '#{httpResponse.response}'")
    end

    if parsedResponse['errors']
      return error_response("Got errors from go-ride-details: '#{parsedResponse['errors']}'")
    end

    OpenStruct.new(
      data: OpenStruct.new(
        seconds: parsedResponse['data']['duration_in_seconds'].to_i,
        meters: parsedResponse['data']['distance_in_meters'].to_i,
      )
    )
  end

  private

  def fetch_data
    url = "http://#{GO_RIDE_HOST}:8080/ride_details_by_coords?from=#{from}&to=#{to}"
    EM::HttpRequest.new(url).get # this request is async!
  end

  def error_response(message)
    OpenStruct.new(errors: [{ details: message }])
  end
end
