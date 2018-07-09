require_relative '../ride_price_api'
require 'goliath/test_helper'
require 'pry'

RSpec.describe RidePriceAPI, "#response" do
  include Goliath::TestHelper

  let(:err) do
    Proc.new { |c| fail "HTTP Request failed #{c.response_header}" }
  end

  let(:api_options) { { address: '127.0.0.1' } }
  let(:correct_params) {
    {
      domain: "127.0.0.1:#{@test_server_port}",
      path: '/ride_price',
      query: { from: '55.691662,37.503621', to: '55.809289,37.582365'}
    }
  }

  context "when gets success response from ride-details service" do
    before(:example) do
      allow_any_instance_of(RequestRideDetails).to receive(:fetch_data) {
        OpenStruct.new(
          error: nil,
          response: '{"data":{"duration_in_seconds":700, "distance_in_meters":2000}}'
        )
      }
    end

    it "returns calculated price" do
      with_api(RidePriceAPI, api_options) do
        get_request(correct_params, err) do |c|
          expect(c.response_header.status).to eq(200)

          # 250 + 2*20 + 12*20 = 530
          expect(c.response).to eq('{"data":{"currency":"RUB","cents":53000}}')
        end
      end
    end
  end

  context "when gets error response from ride-details service" do
    before(:example) do
      allow_any_instance_of(RequestRideDetails).to receive(:fetch_data) {
        OpenStruct.new(
          error: nil,
          response: '{"errors":[{"details":"Stubbed error occured"}]}'
        )
      }
    end

    it "returns received error" do
      with_api(RidePriceAPI, api_options) do
        get_request(correct_params, err) do |c|
          expect(c.response_header.status).to eq(200)
          expect(c.response).to eq('{"errors":[{"details":"Got errors from go-ride-details: \'Stubbed error occured\'"}]}')
        end
      end
    end
  end

  context "when gets http error from ride-details service" do
    before(:example) do
      allow_any_instance_of(RequestRideDetails).to receive(:fetch_data) {
        OpenStruct.new(error: 503)
      }
    end

    it "returns corresponding error" do
      with_api(RidePriceAPI, api_options) do
        get_request(correct_params, err) do |c|
          expect(c.response_header.status).to eq(200)
          expect(c.response).to eq('{"errors":[{"details":"Got unexpected error from go-ride-details: \'503\'"}]}')
        end
      end
    end
  end

  context "when gets required parameter 'from' missing" do
    it "returns missing required param error" do
      with_api(RidePriceAPI, api_options) do
        params = correct_params
        params[:query].delete(:from)

        get_request(params, err) do |c|
          expect(c.response_header.status).to eq(200)
          expect(c.response).to eq('{"errors":[{"details":"Required params missing (\'from\' and \'to\' are required)"}]}')
        end
      end
    end
  end

  context "when gets required parameter 'from' missing" do
    it "returns missing required param error" do
      with_api(RidePriceAPI, api_options) do
        params = correct_params
        params[:query].delete(:to)

        get_request(params, err) do |c|
          expect(c.response_header.status).to eq(200)
          expect(c.response).to eq('{"errors":[{"details":"Required params missing (\'from\' and \'to\' are required)"}]}')
        end
      end
    end
  end

  context "when gets request on another endpoint" do
    it "returns 404" do
      with_api(RidePriceAPI, api_options) do
        params = correct_params
        params[:path] = "/wrong_path"

        get_request(params, err) do |c|
          expect(c.response_header.status).to eq(404)
          expect(c.response).to eq('')
        end
      end
    end
  end
end
