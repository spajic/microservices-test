require_relative 'tariff'

class CalculatePrice
  attr_reader :tariff_id, :minutes, :kilometers

  def initialize(tariff_id:, minutes:, kilometers:)
    @tariff_id = tariff_id
    @minutes = minutes
    @kilometers = kilometers
  end

  def call()
    calculated_cents = tariff['serviceCents'] +
      tariff['costPerMinuteCents'] * minutes +
      tariff['costPerKmCents'] * kilometers

    total_cents = [calculated_cents, tariff['minimalPriceCents']].max

    { currency: tariff['currencyCode'], cents: total_cents }
  end

  def tariff
    @tariff ||= Tariff.by_id(tariff_id)
  end
end
