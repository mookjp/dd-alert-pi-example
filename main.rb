#!/usr/loal/bin/ruby

require 'dogapi'

API_KEY=ENV['DD_API_KEY']
APP_KEY=ENV['DD_APP_KEY']
dog = Dogapi::Client.new(API_KEY, APP_KEY)

def on()
  pp 'on'
end

def off()
  pp 'off'
end

loop do
  alart_num = dog.get_all_monitors(:group_states => ['alert'])[1].select do |item|
    item['overall_state'] != 'OK'
  end.size

  if alart_num > 0
    on()
  else
    off()
  end

  sleep 5
end
