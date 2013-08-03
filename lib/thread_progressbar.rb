require 'ffi-ncurses'

class ThreadProgressBarItem
  attr_accessor :value, :label, :status

  def initialize
    @value  = 0
    @label  = "New thread"
    @status = ''
  end
end

class ThreadProgressBar
  include FFI::NCurses

  attr_accessor :label_width, :status_width, :value_width
  
  def initialize
    @threads = Hash.new
    @mutex = Mutex.new
    @label_width  = 20
    @status_width = 10
    @value_width  = 6
  end
  
  def <<(thread)
    if thread.is_a?(Thread)
      @mutex.synchronize {
        return @threads[thread] = ThreadProgressBarItem.new
      }
    end
  end
  
  def add_current
    self << Thread.current
  end
  
  def list
    @mutex.synchronize {
      @threads.each_pair do |key, value|
        puts ">> #{key} = #{value}"
      end
    }
  end
  
  def update_thread(thread, value)
    return if not thread.is_a?(Thread)
    @mutex.synchronize {
      @threads[thread].value = value
    }
  end
  
  def update(value)
    self.update_thread(Thread.current, value)
  end
  
  def increment_thread(thread, value)
    return if not thread.is_a?(Thread)
    @mutex.synchronize {
      @threads[thread].value =  @threads[thread].value + value
    }
  end
  
  def increment(value)
    self.increment_thread(Thread.current, value)
  end
  
  def status_thread(thread, value)
    return if not thread.is_a?(Thread)
    @mutex.synchronize {
      @threads[thread].status =  value
    }
  end
  
  def status(value)
    self.status_thread(Thread.current, value)
  end
  
  def label_thread(thread, value)
    return if not thread.is_a?(Thread)
    
    @mutex.synchronize {
      @threads[thread].label =  value
    }
  end
  
  def label(value)
    self.label_thread(Thread.current, value)
  end
  
  def format
    "%2d: %-#{@label_width}s %-#{@status_width}s %#{@value_width}d%% %s"
  end
  
  def draw
    move(0,0)
    clear
    refresh
    @mutex.synchronize {
      count = 0
      @threads.each_value do |item|
        move(count,0)
        addstr sprintf(format, count, item.label, item.status, item.value, '#' * item.value)
        refresh
        count = count + 1
      end
    }
  end
  
  def run
    @running = true
    initscr
    FFI::NCurses.curs_set 0
    Thread.new do 
      while @running do
        draw
        sleep 1
      end
    end
  end
  alias start run
  
  def stop
    @running = false
  end
end
