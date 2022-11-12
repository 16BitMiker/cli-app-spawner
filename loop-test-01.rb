#!/opt/homebrew/opt/ruby/bin/ruby

n = 0
loop do
	puts %Q|%05d --- Oh hai!| % n += 1
	sleep(rand(10) + 5)
end

__END__