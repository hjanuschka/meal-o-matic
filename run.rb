require 'serialport'
require 'stm_api'

class MealOMatic
  attr_accessor :device, :baud, :cents_per_signal, :credit, :donate_rate, :serial_port, :userhash, :thread, :mutex
  def initialize
    @device = ARGV[1]
    @baud = 9600
    @cents_per_signal = 10
    @credit = 0
    @donate_rate = 40
    @userhash = ARGV[0]
    @serial_port = SerialPort.new @device, @baud, 8, 1, SerialPort::NONE
    @mutex = Mutex.new

    self.thread = []
    self.thread << Thread.new do
      puts 'Donation thread started'
      donation_thread
    end

    puts "initialize Coin Acceptor Donation System!!! Lets make the world a better place!"
  end

  def donation_thread
    loop do
      @mutex.synchronize do
        donate_now
      end
      puts "Credit Left: #{@credit}"
      sleep 10
    end
  end

  def listen_for_coins
    # @credit = 86
    loop do
      r = serial_port.read(1)
      @mutex.synchronize do
        @credit += cents_per_signal
      end
    end
  end

  def donate_now
    api = StmApi::Donation.new(userhash: @userhash, currency: 'EUR', team_id: 'meal-o-matic')
    donates = @credit / @donate_rate
    burger = []
    for i in 1..donates.floor
      result = api.donate(amount:  (@donate_rate.to_f / 100).to_s)
      if !result
        puts 'Donation failed'
      else
        @credit -= @donate_rate
        burger << "🍔"
      end
    end
    spent = (burger.length * @donate_rate).to_f / 100
    if burger.length > 0
      puts "Donated #{burger.length} meals, worth #{spent} EUR - these are:"
      puts burger.join(" ")
    end

    # result = api.donate(amount: '0.4')
  end
end

mom = MealOMatic.new
mom.listen_for_coins
