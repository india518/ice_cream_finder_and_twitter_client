require 'nokogiri'
require 'json'
require 'rest-client'

def get_response(request)
  response_str = RestClient.get(request)
  JSON.parse(response_str)
end

#Step 1, get our latitude/longitude

puts "Enter your location and I'll find you good ice cream."
# user_address = gets.chomp.gsub(' ', '+')
user_address = "160 Folsom St San Fransicso 94105".gsub(' ', '+')
request = "http://maps.googleapis.com/maps/api/geocode/json"
request += "?address=#{user_address}&sensor=false"
response = get_response(request)
#puts JSON.pretty_generate(response)
user_latlng = response['results'][0]['geometry']['location']



#step 2: give our location to Places API and ask for ice cream places

#Places API key:
Places_API_Key = "AIzaSyALm2QA3GrjC3KriARJyawhJG-sw_qbLmo"

places_request = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
places_request << "?key=#{Places_API_Key}"
places_request << "&location=#{user_latlng['lat']},#{user_latlng['lng']}"
places_request << "&radius=500"
places_request << "&sensor=false"
places_request << "&keyword=ice+cream"
places_request << "&type=food"

puts places_request

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
shop = gets.to_i

p shop

#step 3: get directions to ONE ice cream shop
# (user selected?)