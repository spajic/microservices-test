require 'goliath'
require 'em-synchrony/em-http'
require 'json'
require 'pry'

class RidePriceAPI < Goliath::API
  use Goliath::Rack::Params # parse & merge query and body parameters

  def response(env)
    return [404, {}, ''] unless env['PATH_INFO'] == '/ride_price'

    from = params['from']
    to = params['to']

    url = "http://localhost:8080/ride_details_by_coords?from=#{from}&to=#{to}"
    http = EM::HttpRequest.new(url).get # this request is async!

    data = JSON.parse(http.response)['data']

    resp = {
      data: {
        duration: data['duration_in_seconds'].to_i,
        distance: data['distance_in_meters'].to_i,
      }
    }
    [200, {'Content-Type' => 'application/javascript'}, resp.to_json ]
  end
end
