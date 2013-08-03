#!/usr/bin/env jruby

require 'thread'
require_relative '../lib/thread_progressbar'

Signal.trap("INT") do
  FFI::NCurses.endwin
  FFI::NCurses.curs_set 1
  exit!
end


states = ['starting', 'running', 'stopping', 'stopped']

labels = %w[Illinois Indiana Iowa Kansas Kentucky Louisiana Maine Maryland Massachusetts Michigan Minnesota Mississippi Missouri Montana Nebraska]

tbar = ThreadProgressBar.new

20.times do
  Thread.new do
    tbar.add_current
    begin
      tbar.label labels.sample
    rescue Exception => e
      puts e.message
    end
    loop do
      sleep rand(4)
      tbar.increment rand(4)
      tbar.status states.sample
    end
  end
end

tbar << Thread.new do
    tbar.label "Total"
    tbar.status ''
    loop do
      sleep rand(4)
      tbar.increment 1
    end
end


tbar.run
tbar.list

sleep 1000

tbar.stop

