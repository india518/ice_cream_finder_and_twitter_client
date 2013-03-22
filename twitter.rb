require 'launchy'
require 'oauth'
require 'json'
require 'addressable/uri'
require './secrets'

CONSUMER = OAuth::Consumer.new(
  CONSUMER_KEY, CONSUMER_SECRET, :site => "https://twitter.com")
  # REV: Top 2 lines can be refactored into an Oauth_Loader class

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
        :screen_name => @user_name # REV: Use your user_name getter
      }
    ).to_s
    response = EndUser.access_token.get(request).body
    status_array = JSON.parse(response)
    make_status_list(status_array)
  end

  def make_status_list(status_array)
  # REV: Method name should be 'status_list'; that's what it returns
    list = []
    status_array.each do |status|
      status = Status.new(@user_name,status['text'])
      list << status
    end
    list
  end

end

class EndUser < User

  # REV: @@access_token can be declared & set to nil here (optional)

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
    # REV: The first part of this method could be refactored into an Oauth_Loader class.
    @@access_token = request_token.get_access_token(:oauth_verifier => oauth_verifier)
    @@current_user = EndUser.new(user_name)
  end

  def timeline
    EndUser.access_token.get("http://api.twitter.com/1.1/statuses/home_timeline.json").body
  end

  def dm(target_user, message)
    post_message = Addressable::URI.new(
      :scheme => "https",
      :host => "api.twitter.com",
      :path => "1.1/direct_messages/new.json",
      :query_values => {
        :text => message,
        :screen_name => @user_name
      }
    ).to_s
    EndUser.access_token.post(post_message)
  end

  def tweet(message)
    tweet_status = Addressable::URI.new(
      :scheme => "https",
      :host => "api.twitter.com",
      :path => "1.1/statuses/update.json",
      :query_values => {
        :status => message
      }
    ).to_s
    EndUser.access_token.post(tweet_status)
  end
end

class Status
  attr_accessor :user, :message

  def initialize(user, message)
    @user = user
    @message = message
  end

  # def mentions
  #   # @message.
  # end
  #
  # def hashtags
  # end
end


