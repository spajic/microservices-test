require 'json'

class Tariff
  TARIFFS_FILE = 'tariffs.json'.freeze

  def self.by_id(id)
    @tariffs ||= JSON.parse File.read(TARIFFS_FILE)
    @tariffs.find {|t| t['id'] == id }
  end
end
