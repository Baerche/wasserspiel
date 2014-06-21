run:
	cat makefile
	pkill minetest || true
	
	#minetest
	
	minetest --go --name debugger
	
	#minetest --gameid minetest --worldname "aa" --go
	
	#cat ~/.minetest/minetest.conf
	
menu:
	pkill minetest || true
	minetest


