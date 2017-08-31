require 'rest-client'
require 'json'
require 'sequel'
require 'pg'

DB_STRING = ''
DB = Sequel.connect(ENV['BIKESTALKER_PG_URL'])
STATION_INFO_URL = 'https://gbfs.citibikenyc.com/gbfs/en/station_information.json'
STATION_STATUS_URL = 'https://gbfs.citibikenyc.com/gbfs/en/station_status.json'

DB.create_table? :stations do
  primary_key :id
  String :name
  Integer :capacity
  Numeric :latitude
  Numeric :longitude
end

DB.create_table? :station_states do
  primary_key :id
  foreign_key :station_id, :stations
  DateTime :reported
  Integer :docks_available
  Integer :bikes_available
  Integer :docks_disabled
  Integer :bikes_disabled

  index :station_id
  index :reported
  index [:station_id, :reported], :unique => true
end

class Station < Sequel::Model
end

class StationState < Sequel::Model
end

def insert_stations
  response = RestClient.get(STATION_INFO_URL)
  stations = JSON.parse(response.body)["data"]["stations"]
  Station.unrestrict_primary_key
  stations.each do |station|
    Station.find_or_create(:id => station["station_id"].to_i) do |s|
      s.id = station["station_id"].to_i
      s.name = station["name"]
      s.capacity = station["capacity"]
      s.latitude = station["lat"]
      s.longitude = station["lon"]
    end
  end
end

def insert_station_state(state)
  StationState.create(
    :station_id => state['station_id'].to_i,
    :reported => Time.at(state['last_reported']).to_datetime,
    :docks_available => state['num_docks_available'],
    :bikes_available => state['num_bikes_available'],
    :docks_disabled => state['num_docks_disabled'],
    :bikes_disabled => state['num_docks_disabled']
    )
rescue Sequel::UniqueConstraintViolation
  # catch error when we try to insert a (station_id, reported time) which already exists
  return
end

def log_station_states
  response = RestClient.get(STATION_STATUS_URL)
  stations = JSON.parse(response.body)["data"]["stations"]
  stations.each { |s| insert_station_state(s) }
end

def main
  puts "fetching station list"
  insert_stations
  puts "fetching statuses"
  log_station_states
  puts "done!"
end

main