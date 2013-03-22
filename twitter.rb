require 'launchy'
require 'oauth'
require 'yaml'
require 'json'
require 'addressable/uri'
require './secrets'

CONSUMER = OAuth::Consumer.new(
  CONSUMER_KEY, CONSUMER_SECRET, :site => "https://twitter.com")

class User
  attr_accessor :user_name

  def initialize(user_name)
    @user_name = user_name
  end

  def statuses
    request = Addressable::URI.new(
      :scheme => "https",
      :host => "api.twitter.com",
      :path => "/1.1/statuses/user_timeline.json",
      :query_values => {
        :screen_name => @user_name
      }
    ).to_s
    p request
    p EndUser.access_token
    EndUser.access_token.get(request).body
  end

end

class EndUser < User

  def self.access_token
    @@access_token
  end

  def self.current_user
    @@current_user
  end

  def self.login(user_name)
    request_token = CONSUMER.get_request_token
    authorize_url = request_token.authorize_url
    puts "Go to this URL: #{authorize_url}"
    Launchy.open(authorize_url)
    puts "Login, and type your verification code in"
      oauth_verifier = gets.chomp
    @@access_token = request_token.get_access_token(:oauth_verifier => oauth_verifier)
    @@current_user = EndUser.new(user_name)
  end

  def dm(message)
    p access_token.post("https://api.twitter.com/1.1/direct_messages/new.json")
  end

  def timeline
    EndUser.access_token.get("http://api.twitter.com/1.1/statuses/home_timeline.json").body
  end

end

class Status

  attr_accessor :user, :message

  def initialize(user, message)
    @user = user
    @message = message
  end

end



# access_token = request_access_token
# p access_token
# p User.timeline(access_token)
# User.new(Grumpy_Coworker)

class Square
  def initialize
    if @@count
      @@count += 1
    else
      @@count = 1
    end
  end

  def self.count
    @@count
  end
end
