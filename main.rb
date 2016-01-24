#!/usr/loal/bin/ruby

require 'dogapi'
require 'wiringpi2'

API_KEY=ENV['DD_API_KEY']
APP_KEY=ENV['DD_APP_KEY']
dog = Dogapi::Client.new(API_KEY, APP_KEY)

PIN_NUMBER = 2

class SimpleLogger
  MODE = { :DETAIL => 'DETAIL', :SUMMARY => 'SUMMARY' }
  
  @mode
  @switch_count
  @on_count
  @off_count
  
  def initialize(mode)
    @mode = mode
    @switch_count = 0
    @on_count = 0
    @off_count = 0
  end
  
  def log(message)
    if @mode == MODE[:DETAIL]
      log_detail(message)
    else
      log_summary(message)
    end
  end
  
  def log_detail(message)
    pp "[#{Time.now}] - #{message}"
  end
  
  def log_summary(message)
    @switch_count += 1
  
    if message == 'on'
      @on_count += 1
    else
      @off_count += 1
    end
  
    if @switch_count > 1000
      pp "[#{Time.now}] - on_count: #{@on_count} off_count: #{@off_count}"
      @switch_count = 0
      @on_count = 0
      @off_count = 0
    end
  end
end


io = WiringPi::GPIO.new do |gpio|
  gpio.pin_mode(2, WiringPi::OUTPUT)
end

logger = SimpleLogger.new(SimpleLogger::MODE[:DETAIL])

loop do
  alart_num = dog.get_all_monitors(:group_states => ['alert'])[1].select do |item|
    pp item
    item['overall_state'] != 'OK'
  end.size

  if alart_num > 0
    io.digital_write(PIN_NUMBER, WiringPi::HIGH)
    logger.log('on')
  else
    io.digital_write(PIN_NUMBER, WiringPi::LOW)
    logger.log('off')
  end

  sleep 5
end
