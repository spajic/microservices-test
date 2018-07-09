require_relative '../calculate_price'

RSpec.describe CalculatePrice, "#call" do
  before do
    allow(Tariff).to receive(:by_id) {
      {
        "currencyCode" => "RUB",
        "serviceCents" => 250_00,
        "costPerMinuteCents" => 20_00,
        "costPerKmCents" => 20_00,
        "minimalPriceCents" => 500_00,
      }
    }
  end

  context "when calculated price is less than minimal price" do
    it "returns minimal price" do
      price = CalculatePrice.new(tariff_id: 'stub', minutes: 1, kilometers: 1).call
      expect(price[:currency]).to eq 'RUB'
      expect(price[:cents]).to eq 500_00
    end
  end

  context "when calculated price is more than minimal price" do
    it "returns price according to tariff calculation" do
      price = CalculatePrice.new(tariff_id: 'stub', minutes: 30, kilometers: 10).call
      expect(price[:currency]).to eq 'RUB'
      expect(price[:cents]).to eq 1050_00 # 250 + 20*30 + 20*10 = 1050
    end
  end
end
