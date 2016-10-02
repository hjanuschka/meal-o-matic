require 'serialport'
require 'stm_api'


class MealOMatic
	attr_accessor :device, :baud, :cents_per_signal, :credit, :donate_rate, :serial_port, :userhash
	def initialize()
		@device = ARGV[1]
		@baud = 9600
		@cents_per_signal = 10
		@credit = 0
		@donate_rate = 40
		@userhash = ARGV[0];
		@serial_port = SerialPort.new @device, @baud, 8, 1, SerialPort::NONE
		
	end


	def listen_for_coins
		loop do
			if @credit > @donate_rate
				donate_now
			end
			#puts "Current Un-Donated Credits: #{@credit}"
		  r = serial_port.read(1)
		  @credit += cents_per_signal
			
		end
	end
	def donate_now
		api = StmApi::Donation.new(userhash: @userhash, currency: 'EUR', team_id: 'meal-o-matic')
		donates = @credit/@donate_rate
		burger = [];
		for i in 1..donates.floor
			@credit -= @donate_rate
			burger << "🍔"
		end
		puts "Donated: #{burger.length} that is:"
		puts burger.join(" ")
		puts "Credit Left: #{@credit}"
		#result = api.donate(amount: '0.4')
	end
end

mom = MealOMatic.new()
mom.listen_for_coins()


