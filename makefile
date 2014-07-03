run:
	cat makefile
	pkill minetest || true
	pkill freeminer || true
	
	minetest --config tools/my-minetest.conf &
	#~/freeminer-4.9.3/bin/freeminer --config tools/my-freeminer.conf &
	
	#minetest --go --name debugger
	
	#minetest --gameid minetest --worldname "aa" --go
	
	#cat ~/.minetest/minetest.conf
	
menu:
	pkill minetest || true
	minetest


