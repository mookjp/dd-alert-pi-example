#!/usr/loal/bin/ruby

require 'dogapi'
require 'wiringpi2'

API_KEY=ENV['DD_API_KEY']
APP_KEY=ENV['DD_APP_KEY']
dog = Dogapi::Client.new(API_KEY, APP_KEY)

PIN_NUMBER = 2

Class SimpleLogger
  MODE = { :DETAIL => 'DETAIL', :SUMMARY => 'SUMMARY' }

  def new(mode)
    self.mode = mode
    self.switch_count = 0
    self.on_count = 0
    self.off_count = 0
  end

  def log(message)
    if mode == MODE[:DETAIL]
      log_detail(message)
      return
    end
    log_summary(message)
  end

  def log_detail(message)
    pp "[#{Time.now}] - #{message}"
  end

  def log_summary(message)
    self.switch_count += 1
    
    if message == 'on'
      self.on_count += 1
    else
      self.off_count += 1
    end
    
    if self.switch_count > 1000
      pp "[#{Time.now}] - on_count: #{self.on_count} off_count: #{self.off_count}"
      self.switch_count = 0
      self.on_count = 0
      self.off_count = 0
    end
  end
end

def on(io, pin_number)
  io.digital_write(pin_number, WiringPi::HIGH)
  logger.log('on')
end

def off(io, pin_number)
  io.digital_write(pin_number, WiringPi::LOW)
  logger.log('off')
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
    on(io, PIN_NUMBER)
  else
    off(io, PIN_NUMBER)
  end

  sleep 5
end
