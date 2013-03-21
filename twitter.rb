require 'launchy'
require 'oauth'
require 'yaml'
require 'secrets.rb'

CONSUMER_KEY = PvtoobjZOCIfNduWZujWEA

class User
  attr_accessor :real_name, :user_name

  def initialize(real_name, user_name)
    @real_name, @user_name = real_name, user_name
    @statuses = []
  end

  def dm(message)
  end



end


class Status

  def initialize(user, message)
    @user = user
    @message = message
  end



end