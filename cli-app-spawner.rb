#!/opt/homebrew/opt/ruby/bin/ruby -rjson -rcolorize
#          _ _                               _ _         
#    /\/\ (_) | _____ _ __    /\/\   ___  __| (_) __ _   
#   /    \| | |/ / _ \ '__|  /    \ / _ \/ _` | |/ _` |  
#  / /\/\ \ |   <  __/ |    / /\/\ \  __/ (_| | | (_| |  
#  \/    \/_|_|\_\___|_|    \/    \/\___|\__,_|_|\__,_|  
#   
# App Spawner v0.1 (rubys / perl / bash)
# by https://miker.media

# ####################################### GLOBALS

$apps    = [];
$spawned = {};

# ####################################### LAMBDAS

$forkMe = ->(choice) {
	
	unless File.directory?(%q|logs|) then
		Dir.mkdir %q|logs|
	end;
	
	time = Time.new.to_i;
	log = %Q|logs/#{time}-#{$apps[choice].sub(%r~\.[[:alnum:]]+$~,%q||)}-my.log|;
	
	run = '';
	
	case $apps[choice].sub(%r~^.*\.(rb|pl|sh)$~) { $1 };
	
		when %r~rb~;
			run = %q|ruby|;
		when %r~pl~;
			run = %q|perl|;
		when %r~sh~;
			run = %q|bash -c|;
	end;
	
	cmd = %Q|#{ %x~type #{run}~.chomp.sub(%r~^ruby\sis\s~,%q||) } #{__dir__}/#{$apps[choice]}|;
	r, w = IO.pipe;

	$spawned[Process.spawn(cmd, [:out, :err] => log).to_i] = $apps.delete($apps[choice]);

};

$scanFiles = -> () {
	Dir.glob(%q|*|).each { |f|
		
		if File.file?(f) and f.match(%r~(?:pl|rb)$~) then
			next if f.match(%r~#{__FILE__.gsub(%r~^[^/]*?/~,%q||)}~);
			$apps.push(f.chomp);
		end;
		
	};
};

$displayMenu = -> () { 
	
	print %Q|\e[H\e[2J|;
	
	puts %q|~|*25;
	
	if $apps.length >= 1 then
		puts %q|> type app # to run:|.yellow;
		$apps.each_with_index { |v,k| puts %Q|#{k}: #{v}|; };
	end;
	
	if $spawned.length >= 1 then
		puts %q|> type pid # to quit:|.yellow;
		$spawned.each { |k,v| puts %Q|#{ k }: #{ v }|; };
	end;
	
	puts %q|~|*25;

};

$killPID = -> (pid) {
	
	puts %q|> killing process | + %Q|#{pid}: #{$spawned[pid]}|.red;
	Process.kill("HUP", pid);
	$apps.unshift($spawned[pid]);
	$spawned.delete(pid);
	
};

$runMe = -> () {
	
	loop {
		
		$displayMenu.===();
		print %q|> [q to quit]: |.blue;
		choice = gets.chomp.gsub(%r~\s+~,%q||);
		
		if choice.match(%r~q(?:uit)?~i) then
		
			if $spawned.length > 0 then
				$spawned.each { |k,v|
					puts %q|> killing process | + %Q|#{k}: #{v}|.red;
					Process.kill("HUP", k);
				}
			end;
			
			puts %q|> see ya later bye bye, see ya later bye!|.green;
			
			exit 69;
		
		elsif $apps[choice.to_i] 
		
			$forkMe.===(choice.to_i);
		
		elsif $spawned[choice.to_i] then
		
			$killPID.===(choice.to_i);
		
		else
		
			puts %q|> invalid choice, try again!|.red;
		
		end;
		
	};
	
};

# ####################################### INIT

$scanFiles.===();
$runMe.===();

__END__
