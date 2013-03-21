require 'launchy'
require 'oauth'
require 'yaml'
require './secrets'

CONSUMER = OAuth::Consumer.new(
  CONSUMER_KEY, CONSUMER_SECRET, :site => "https://twitter.com")

def request_access_token
  request_token = CONSUMER.get_request_token
  authorize_url = request_token.authorize_url
  puts "Go to this URL: #{authorize_url}"
  Launchy.open(authorize_url)
  puts "Login, and type your verification code in"
    oauth_verifier = gets.chomp
  request_token.get_access_token(:oauth_verifier => oauth_verifier)
end

class User
  attr_accessor :user_name

  def initialize(user_name)
    @user_name = user_name
    @statuses = []
  end

  def dm(message)
  end

  def User.timeline(access_token)
    access_token.get("http://api.twitter.com/1.1/statuses/user_timeline.json").body
  end
end


class Status

  attr_accessor :user, :message

  def initialize(user, message)
    @user = user
    @message = message
  end

end


access_token = request_access_token
p access_token
p User.timeline(access_token)
