run:
	cat makefile
	pkill minetest || true
	pkill freeminer || true
	
	#(~/minetest-4.10-git/bin/minetest --config tools/my-minetest.conf; xrandr --size 1280x1024) &
	(~/freeminer-4.9.3-git/bin/freeminer --config tools/my-freeminer.conf; xrandr --size 1280x1024)
	
	#minetest --config tools/my-minetest.conf &
	
	
	#minetest --go --name debugger
	
	#minetest --gameid minetest --worldname "aa" --go
	
	#cat ~/.minetest/minetest.conf
	
menu:
	pkill minetest || true
	minetest


