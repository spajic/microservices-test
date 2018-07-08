require 'goliath'
require 'em-synchrony/em-http'
require 'json'
require 'pry'

require_relative 'calculate_price'

class RidePriceAPI < Goliath::API
  DEFAULT_TARIFF_ID = 1
  SECONDS_IN_MINUTE = 60.0
  METERS_IN_KILOMETER = 1000.0

  use Goliath::Rack::Params # parse & merge query and body parameters

  def response(env)
    return [404, {}, ''] unless env['PATH_INFO'] == '/ride_price'

    from = params['from']
    to = params['to']

    url = "http://localhost:8080/ride_details_by_coords?from=#{from}&to=#{to}"
    http = EM::HttpRequest.new(url).get # this request is async!

    data = JSON.parse(http.response)['data']

    price = CalculatePrice.new(
      tariff_id: DEFAULT_TARIFF_ID,
      minutes: (data['duration_in_seconds'].to_i / SECONDS_IN_MINUTE).ceil,
      kilometers: (data['distance_in_meters'].to_i / METERS_IN_KILOMETER).ceil,
    ).call
    [200, {'Content-Type' => 'application/javascript'}, { data: price }.to_json]
  end
end
