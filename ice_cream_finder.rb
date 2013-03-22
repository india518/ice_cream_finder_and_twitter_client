require 'nokogiri'
require 'json'
require 'rest-client'
require 'addressable/uri'

Places_API_Key = "AIzaSyALm2QA3GrjC3KriARJyawhJG-sw_qbLmo"

def get_response(request)
  response_str = RestClient.get(request.to_s)
  JSON.parse(response_str)
end

puts "Enter your location and I'll find you good ice cream."
# user_address = gets.chomp.gsub(' ', '+')
user_address = "160 Folsom St San Fransicso 94105".gsub(' ', '+')
# REV: Addressable:URI does the + to space conversion for you

request = Addressable::URI.new(
  :scheme => "http",
  :host => "maps.googleapis.com",
  :path => "/maps/api/geocode/json",
  :query_values => {
    :address => "#{user_address}",
    :sensor => "false"
  }
)
response = get_response(request)

user_latlng = response['results'][0]['geometry']['location']
# REV: Recommend to define lat and lng separately
places_request = Addressable::URI.new(
  :scheme => "https",
  :host => "maps.googleapis.com",
  :path => "/maps/api/place/nearbysearch/json",
  :query_values => {
    :key => "#{Places_API_Key}",
    :location => "#{user_latlng['lat']},#{user_latlng['lng']}",
    :radius => "500",
    :sensor => "false",
    :keyword => "ice+cream",
    :type => "food"
  }
)
places_response = get_response(places_request)

ice_cream_shops = {}
places_response["results"].each do |result|
  ice_cream_shop_name = result["name"]
  ice_cream_shop_location = result["geometry"]["location"]
  ice_cream_shops[ice_cream_shop_name] = ice_cream_shop_location
end

puts "Ice cream shop choices:"
ice_cream_shops.keys.each_with_index do |shop_name, index|
  puts "#{index} : #{shop_name}"
end

puts "Which number shop would you like directions to?"
choice = gets.to_i
#REV: Needs an error check in case a user enters a non-number or a #number that is out of range (Google returns up to 20 values)
name = ice_cream_shops.keys[choice]
puts "Directions to #{name}:"
dest_latlng = ice_cream_shops[name]

directions_request = Addressable::URI.new(
  :scheme => "http",
  :host => "maps.googleapis.com",
  :path => "/maps/api/directions/json",
  :query_values => {
    :origin => "#{user_latlng['lat']},#{user_latlng['lng']}",
    :destination => "#{dest_latlng['lat']},#{dest_latlng['lng']}",
    :radius => "500",
    :sensor => "false",
    :mode => "walking"
  }
)
directions_result = get_response(directions_request)

# Use to pretty up interface later:
#directions_result["routes"][0]["legs"][0]["start_address"]
steps = directions_result["routes"][0]["legs"][0]["steps"]
steps.each_with_index do |step, index|
  parsed_html_instructions = Nokogiri::HTML(step["html_instructions"])
  puts "Step #{index + 1}: #{parsed_html_instructions.text}"
end
#directions_result["routes"][0]["legs"][0]["end_address"]
