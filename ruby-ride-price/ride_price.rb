require 'goliath'
require 'em-synchrony/em-http'
require 'json'

require_relative 'calculate_price'
require_relative 'request_ride_details'

class RidePriceAPI < Goliath::API
  DEFAULT_TARIFF_ID = 1
  SECONDS_IN_MINUTE = 60.0
  METERS_IN_KILOMETER = 1000.0

  use Goliath::Rack::Params # parse & merge query and body parameters

  def response(env)
    return [404, {}, ''] unless env['PATH_INFO'] == '/ride_price'

    ride_details =
      RequestRideDetails.new(from: params['from'], to: params['to']).call

    return response_with({ errors: ride_details.errors }) if ride_details.errors

    price = CalculatePrice.new(
      tariff_id: DEFAULT_TARIFF_ID,
      minutes: (ride_details.data.seconds / SECONDS_IN_MINUTE).ceil,
      kilometers: (ride_details.data.meters / METERS_IN_KILOMETER).ceil,
    ).call
    response_with({ data: price })
  end

  private

  def response_with(body)
    [200, {'Content-Type' => 'application/javascript'}, body.to_json]
  end
end
